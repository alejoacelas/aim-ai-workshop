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

# --- Function-level assertion helpers ---

assert_fn_output() {
  local desc="$1" expected="$2"; shift 2
  local got
  got=$("$@" 2>/dev/null)
  if [[ "$got" == "$expected" ]]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc"; FAIL=$((FAIL + 1))
    echo "    expected: $expected"
    echo "    got:      $got"
  fi
}

assert_fn_output_contains() {
  local desc="$1" pattern="$2"; shift 2
  local got
  got=$("$@" 2>/dev/null)
  if echo "$got" | grep -qF "$pattern"; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc"; FAIL=$((FAIL + 1))
    echo "    expected to contain: $pattern"
    echo "    got: $got"
  fi
}

# Source helpme.sh to get access to its functions (source guard prevents dispatcher from running)
source "$HELPME"

echo ""
echo "-- json_escape --"
assert_fn_output "backslash is escaped"       'a\\b'          json_escape 'a\b'
assert_fn_output "double quotes are escaped"   'say \"hi\"'    json_escape 'say "hi"'
assert_fn_output "newline is escaped"          'line1\nline2'  json_escape $'line1\nline2'
assert_fn_output "carriage return is escaped"  'a\rb'          json_escape $'a\rb'
assert_fn_output "tab is escaped"              'a\tb'          json_escape $'a\tb'
assert_fn_output "combined escapes"            'a\\b \"hi\"\nc' json_escape $'a\\b "hi"\nc'

echo ""
echo "-- truncate --"
assert_fn_output "short string unchanged"      "hello"         truncate "hello" 10
assert_fn_output "exact limit unchanged"       "hello"         truncate "hello" 5
assert_fn_output "over limit is cut"           "hello"         truncate "hello world" 5

echo ""
echo "-- parse_json_field --"
assert_fn_output "string field"                "alice"         parse_json_field '{"name":"alice"}' name
assert_fn_output "boolean field"               "true"          parse_json_field '{"ok":true}' ok
assert_fn_output "missing field returns empty" ""              parse_json_field '{"name":"alice"}' age

# List field: parse_json_field should output each element on its own line
_test_list_output() {
  parse_json_field '{"items":["a","b"]}' items
}
assert_fn_output "list field outputs elements" $'a\nb' _test_list_output

# Grep fallback: hide python3 so parse_json_field falls back to grep
_test_grep_fallback() {
  local orig_path="$PATH"
  # Create a temp dir with only basic commands (no python3)
  local fake_bin; fake_bin=$(mktemp -d)
  # Link only the essentials
  for cmd in grep sed echo printf cat head; do
    local cmd_path; cmd_path=$(command -v "$cmd" 2>/dev/null) && ln -sf "$cmd_path" "$fake_bin/$cmd"
  done
  PATH="$fake_bin" parse_json_field '{"name":"bob"}' name
  PATH="$orig_path"
  rm -rf "$fake_bin"
}
assert_fn_output "grep fallback for string field" "bob" _test_grep_fallback

echo ""
echo "-- build_log_history --"

# Test: no file exists → outputs []
_test_log_no_file() {
  local tmpdir; tmpdir=$(mktemp -d)
  LOG_FILE="$tmpdir/nonexistent.jsonl" build_log_history
  rm -rf "$tmpdir"
}
assert_fn_output "no log file returns []"      "[]"            _test_log_no_file

# Test: empty file → outputs []
_test_log_empty_file() {
  local tmpdir; tmpdir=$(mktemp -d)
  touch "$tmpdir/log.jsonl"
  LOG_FILE="$tmpdir/log.jsonl" build_log_history
  rm -rf "$tmpdir"
}
assert_fn_output "empty log file returns []"   "[]"            _test_log_empty_file

# Test: 3 entries → outputs JSON array with all 3
_test_log_3_entries() {
  local tmpdir; tmpdir=$(mktemp -d)
  printf '{"a":1}\n{"a":2}\n{"a":3}\n' > "$tmpdir/log.jsonl"
  LOG_FILE="$tmpdir/log.jsonl" build_log_history
  rm -rf "$tmpdir"
}
assert_fn_output "3 entries returns all 3"     '[{"a":1},{"a":2},{"a":3}]' _test_log_3_entries

# Test: 7 entries → outputs JSON array with last 5 only
_test_log_7_entries() {
  local tmpdir; tmpdir=$(mktemp -d)
  for i in 1 2 3 4 5 6 7; do echo "{\"a\":$i}"; done > "$tmpdir/log.jsonl"
  LOG_FILE="$tmpdir/log.jsonl" build_log_history
  rm -rf "$tmpdir"
}
assert_fn_output "7 entries returns last 5"    '[{"a":3},{"a":4},{"a":5},{"a":6},{"a":7}]' _test_log_7_entries

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
