#!/usr/bin/env bash
# Test suite for helpme.sh
set -euo pipefail

HELPME="$(cd "$(dirname "$0")/.." && pwd)/helpme.sh"
PASS=0
FAIL=0
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# All tests use an isolated log dir and a fake worker URL to avoid network calls
export HELPME_LOG_DIR="$TEST_DIR"
export HELPME_WORKER_URL="http://localhost:0"  # unreachable — tests don't need the worker

# --- Assertions ---

assert_exit() {
  local desc="$1" expected="$2"; shift 2
  set +e; "$@" >/dev/null 2>&1; local got=$?; set -e
  if [[ "$got" -eq "$expected" ]]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (expected exit $expected, got $got)"; FAIL=$((FAIL + 1))
  fi
}

assert_output_contains() {
  local desc="$1" pattern="$2"; shift 2
  set +e; local output; output=$("$@" 2>&1); set -e
  if echo "$output" | grep -q "$pattern"; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (output did not contain '$pattern')"; FAIL=$((FAIL + 1))
    echo "    got: $(echo "$output" | head -3)"
  fi
}

# --- Tests ---

echo "=== helpme.sh test suite ==="
echo ""

echo "-- help and version --"
assert_exit      "--help exits 0"                    0 bash "$HELPME" --help
assert_exit      "-h exits 0"                        0 bash "$HELPME" -h
assert_exit      "help subcommand exits 0"           0 bash "$HELPME" help
assert_exit      "no args exits 0 (shows help)"      0 bash "$HELPME"
assert_output_contains "--help shows Usage:"         "Usage:" bash "$HELPME" --help
assert_output_contains "--help shows examples"       "Examples:" bash "$HELPME" --help
assert_output_contains "--help shows version"        "v0.2.0" bash "$HELPME" --help

assert_exit      "--version exits 0"                 0 bash "$HELPME" --version
assert_exit      "-v exits 0"                        0 bash "$HELPME" -v
assert_output_contains "--version prints version"    "helpme 0.2.0" bash "$HELPME" --version

echo ""
echo "-- command execution --"
assert_exit      "-- echo hello exits 0"             0 bash "$HELPME" -- echo hello
assert_output_contains "-- echo hello outputs hello" "hello" bash "$HELPME" -- echo hello
assert_exit      "run -- echo hello exits 0"         0 bash "$HELPME" run -- echo hello
assert_exit      "-- false exits non-zero"           1 bash "$HELPME" -- false

echo ""
echo "-- log file --"
# Clear log and run a command so we can inspect the entry
rm -f "$TEST_DIR/log.jsonl"
bash "$HELPME" -- echo logtest >/dev/null 2>&1 || true

if [[ -f "$TEST_DIR/log.jsonl" ]]; then
  echo "  ✓ log file created after run"; PASS=$((PASS + 1))

  LAST_LINE=$(tail -1 "$TEST_DIR/log.jsonl")

  # Check expected fields exist in the log entry
  for field in timestamp command exit_code os shell ok explanation fix_commands duration; do
    if echo "$LAST_LINE" | grep -q "\"$field\""; then
      echo "  ✓ log entry contains '$field'"; PASS=$((PASS + 1))
    else
      echo "  ✗ log entry missing '$field'"; FAIL=$((FAIL + 1))
      echo "    entry: $LAST_LINE"
    fi
  done
else
  echo "  ✗ log file not created"; FAIL=$((FAIL + 1))
fi

echo ""
echo "-- dispatcher routing --"
# Ensure that unknown first args are treated as commands (fallthrough to run)
assert_output_contains "bare command falls through to run" "hello" bash "$HELPME" echo hello

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
