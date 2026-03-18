#!/usr/bin/env bash
set -euo pipefail

HELPME="$(cd "$(dirname "$0")/.." && pwd)/helpme.sh"
PASS=0
FAIL=0
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

export HELPME_LOG_DIR="$TEST_DIR"

# --- Assertion helpers ---

assert_contains() {
  local label="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "    expected to contain: $needle"
    echo "    got: ${haystack:0:300}"
    FAIL=$((FAIL + 1))
  fi
}

assert_equals() {
  local label="$1" actual="$2" expected="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "    expected: $expected"
    echo "    got: $actual"
    FAIL=$((FAIL + 1))
  fi
}

# --- Mock server helper ---

start_mock() {
  local response="$1"
  local port_file="$TEST_DIR/port_$$_$RANDOM"

  python3 -c "
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
response_body = sys.argv[1]
port_file = sys.argv[2]
class H(BaseHTTPRequestHandler):
    def do_POST(self):
        cl = int(self.headers.get('Content-Length', 0))
        self.rfile.read(cl)
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(response_body.encode())
    def log_message(self, *a): pass
s = HTTPServer(('127.0.0.1', 0), H)
with open(port_file, 'w') as f:
    f.write(str(s.server_address[1]))
s.handle_request()
" "$response" "$port_file" &

  MOCK_PID=$!

  # Poll for port file
  local attempts=0
  while [[ ! -s "$port_file" ]] && [[ $attempts -lt 50 ]]; do
    sleep 0.05
    attempts=$((attempts + 1))
  done

  MOCK_PORT=$(cat "$port_file")
  rm -f "$port_file"
}

# Helper: run helpme and capture output + exit code safely under set -e
run_helpme() {
  set +e
  OUTPUT=$("$@" 2>&1)
  EXIT=$?
  set -e
}

# =========================================================
# Test 1: Success path
# =========================================================
echo "Test 1: Success path"

start_mock '{"ok":true,"explanation":"All good","fix_commands":[]}'

run_helpme env HELPME_WORKER_URL="http://127.0.0.1:$MOCK_PORT" bash "$HELPME" -- echo hello

wait "$MOCK_PID" 2>/dev/null || true

assert_equals "exit code is 0" "$EXIT" "0"
assert_contains "output contains explanation" "$OUTPUT" "All good"
assert_contains "log file has ok:true" "$(cat "$TEST_DIR/log.jsonl")" '"ok":true'

# =========================================================
# Test 2: Failure path (no fix commands, avoids tty prompt)
# =========================================================
echo ""
echo "Test 2: Failure path"

# Clear log for clean assertions
> "$TEST_DIR/log.jsonl"

start_mock '{"ok":false,"explanation":"Missing package","fix_commands":[]}'

run_helpme env HELPME_WORKER_URL="http://127.0.0.1:$MOCK_PORT" bash "$HELPME" -- false

wait "$MOCK_PID" 2>/dev/null || true

assert_equals "exit code is 1" "$EXIT" "1"
assert_contains "output contains explanation" "$OUTPUT" "Missing package"
assert_contains "log file has ok:false" "$(cat "$TEST_DIR/log.jsonl")" '"ok":false'

# =========================================================
# Test 3: Worker unreachable
# =========================================================
echo ""
echo "Test 3: Worker unreachable"

> "$TEST_DIR/log.jsonl"

run_helpme env HELPME_WORKER_URL="http://127.0.0.1:1" bash "$HELPME" -- false

assert_equals "exit code is 1" "$EXIT" "1"
assert_contains "output mentions unreachable" "$OUTPUT" "couldn't reach the help service"

# =========================================================
# Test 4: Garbage response (non-JSON)
# =========================================================
echo ""
echo "Test 4: Garbage response"

> "$TEST_DIR/log.jsonl"

start_mock 'not json at all'

run_helpme env HELPME_WORKER_URL="http://127.0.0.1:$MOCK_PORT" bash "$HELPME" -- echo hello

wait "$MOCK_PID" 2>/dev/null || true

assert_equals "exit code is 0 (echo succeeded)" "$EXIT" "0"

# =========================================================
# Test 5: Failure path with fix commands displayed
# =========================================================
echo ""
echo "Test 5: Fix commands displayed"

> "$TEST_DIR/log.jsonl"

start_mock '{"ok":false,"explanation":"Missing package","fix_commands":["npm install"]}'

# The read from /dev/tty will fail in non-interactive mode, but the script
# should still display the fix commands before that. Capture output; ignore
# any exit code weirdness from the tty read failure.
run_helpme env HELPME_WORKER_URL="http://127.0.0.1:$MOCK_PORT" bash "$HELPME" -- false

wait "$MOCK_PID" 2>/dev/null || true

assert_contains "output contains explanation" "$OUTPUT" "Missing package"
assert_contains "output contains fix command" "$OUTPUT" "npm install"

# =========================================================
# Summary
# =========================================================
echo ""
echo "========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "========================================="

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
