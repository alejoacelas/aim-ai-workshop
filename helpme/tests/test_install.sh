#!/usr/bin/env bash
set -euo pipefail

INSTALL_SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/install.sh"
LOCAL_HELPME="$(cd "$(dirname "$0")/.." && pwd)/helpme.sh"
PASS=0
FAIL=0
CLEANUP_DIRS=()

# --- Assertion helpers ---

pass() {
  PASS=$((PASS + 1))
  echo "  PASS: $1"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "  FAIL: $1"
  if [[ -n "${2:-}" ]]; then
    echo "        $2"
  fi
}

assert_exit() {
  local actual="$1" expected="$2" label="$3"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label" "expected exit $expected, got $actual"
  fi
}

assert_file_exists() {
  local path="$1" label="$2"
  if [[ -f "$path" ]]; then
    pass "$label"
  else
    fail "$label" "file does not exist: $path"
  fi
}

assert_file_not_exists() {
  local path="$1" label="$2"
  if [[ ! -f "$path" ]]; then
    pass "$label"
  else
    fail "$label" "file should not exist: $path"
  fi
}

assert_file_contains() {
  local path="$1" pattern="$2" label="$3"
  if [[ -f "$path" ]] && grep -qF "$pattern" "$path" 2>/dev/null; then
    pass "$label"
  else
    fail "$label" "file '$path' does not contain '$pattern'"
  fi
}

assert_file_not_contains() {
  local path="$1" pattern="$2" label="$3"
  if [[ ! -f "$path" ]] || ! grep -qF "$pattern" "$path" 2>/dev/null; then
    pass "$label"
  else
    fail "$label" "file '$path' unexpectedly contains '$pattern'"
  fi
}

assert_executable() {
  local path="$1" label="$2"
  if [[ -x "$path" ]]; then
    pass "$label"
  else
    fail "$label" "file is not executable: $path"
  fi
}

assert_output_contains() {
  local output="$1" pattern="$2" label="$3"
  if echo "$output" | grep -qiF "$pattern" 2>/dev/null; then
    pass "$label"
  else
    fail "$label" "output does not contain '$pattern'"
  fi
}

count_occurrences() {
  local path="$1" pattern="$2"
  grep -cF "$pattern" "$path" 2>/dev/null || echo "0"
}

# --- Test infrastructure ---

make_fake_home() {
  local d
  d=$(mktemp -d)
  CLEANUP_DIRS+=("$d")
  echo "$d"
}

make_mock_curl_bin() {
  # Creates a temp dir with a mock curl script that copies the local helpme.sh
  local fake_bin
  fake_bin=$(mktemp -d)
  CLEANUP_DIRS+=("$fake_bin")
  cat > "$fake_bin/curl" << MOCK
#!/usr/bin/env bash
# Mock curl: copy local helpme.sh to the -o destination
outfile=""
while [[ \$# -gt 0 ]]; do
  case "\$1" in
    -o) outfile="\$2"; shift 2 ;;
    *) shift ;;
  esac
done
if [[ -n "\$outfile" ]]; then
  mkdir -p "\$(dirname "\$outfile")"
  cp "$LOCAL_HELPME" "\$outfile"
fi
MOCK
  chmod +x "$fake_bin/curl"
  echo "$fake_bin"
}

make_telemetry_curl_bin() {
  local fake_bin
  fake_bin=$(make_mock_curl_bin)
  cat > "$fake_bin/curl" << MOCK
#!/usr/bin/env bash
set -euo pipefail
if [[ "\$*" == *"raw.githubusercontent.com"* ]]; then
  outfile=""
  while [[ \$# -gt 0 ]]; do
    case "\$1" in
      -o) outfile="\$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  if [[ -n "\$outfile" ]]; then
    mkdir -p "\$(dirname "\$outfile")"
    cp "$LOCAL_HELPME" "\$outfile"
  fi
  exit 0
fi

printf '%s\n' "\$*" >> "\${HELPME_TEST_CURL_LOG:?}"
{
  printf 'ARGS:%s\n' "\$*"
  printf 'BODY:'
  cat
  printf '\n'
} >> "\${HELPME_TEST_CURL_BODY_LOG:?}"
exit 0
MOCK
  chmod +x "$fake_bin/curl"
  echo "$fake_bin"
}

make_failing_telemetry_curl_bin() {
  local fake_bin
  fake_bin=$(make_mock_curl_bin)
  cat > "$fake_bin/curl" << MOCK
#!/usr/bin/env bash
set -euo pipefail
if [[ "\$*" == *"raw.githubusercontent.com"* ]]; then
  outfile=""
  while [[ \$# -gt 0 ]]; do
    case "\$1" in
      -o) outfile="\$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  if [[ -n "\$outfile" ]]; then
    mkdir -p "\$(dirname "\$outfile")"
    cp "$LOCAL_HELPME" "\$outfile"
  fi
  exit 0
fi

printf '%s\n' "\$*" >> "\${HELPME_TEST_CURL_LOG:?}"
exit 28
MOCK
  chmod +x "$fake_bin/curl"
  echo "$fake_bin"
}

# Run install.sh in a subshell with controlled environment.
# Usage: run_install <fake_home> <fake_bin> [extra env vars as KEY=VAL ...]
# The script is run with bash, but BASH_VERSION and ZSH_VERSION are unset
# inside the shell so the install script relies on $SHELL for detection.
# (Simply using env -u doesn't work because bash re-sets BASH_VERSION on startup.)
run_install() {
  local fake_home="$1"
  local fake_bin="$2"
  shift 2

  local env_args=()
  env_args+=(HOME="$fake_home")
  env_args+=(PATH="$fake_bin:/usr/bin:/bin:/usr/sbin:/sbin")

  # Add any extra env vars passed as arguments
  for arg in "$@"; do
    env_args+=("$arg")
  done

  # Use bash -c with unset to clear BASH_VERSION before eval'ing the script.
  # eval is needed because the script has a { ... } wrapper and exit calls.
  env "${env_args[@]}" bash -c '
    unset BASH_VERSION ZSH_VERSION
    eval "$(cat "$1")"
  ' _ "$INSTALL_SCRIPT" 2>&1
}

cleanup() {
  for d in "${CLEANUP_DIRS[@]}"; do
    rm -rf "$d"
  done
}
trap cleanup EXIT

# --- Tests ---

echo ""
echo "=== install.sh test suite ==="
echo ""

# ---------------------------------------------------------------
# Test 1: Zsh shell — creates .zshrc with PATH line
# ---------------------------------------------------------------
echo "Test 1: Zsh shell creates .zshrc with PATH line"
fake_home=$(make_fake_home)
fake_bin=$(make_mock_curl_bin)
output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/zsh)
exit_code=$?

assert_exit "$exit_code" 0 "install exits 0"
assert_file_exists "$fake_home/.local/bin/helpme" "helpme binary downloaded"
assert_executable "$fake_home/.local/bin/helpme" "helpme binary is executable"
assert_file_exists "$fake_home/.zshrc" ".zshrc created"
assert_file_contains "$fake_home/.zshrc" '.local/bin' ".zshrc contains .local/bin PATH"
echo ""

# ---------------------------------------------------------------
# Test 2: Bash on Linux — modifies .bashrc
# ---------------------------------------------------------------
echo "Test 2: Bash on Linux modifies .bashrc"
fake_home=$(make_fake_home)
fake_bin=$(make_mock_curl_bin)
# Mock uname to return Linux
cat > "$fake_bin/uname" << 'MOCK'
#!/usr/bin/env bash
# Return Linux for -s flag
for arg in "$@"; do
  case "$arg" in
    -s) echo "Linux"; exit 0 ;;
  esac
done
echo "Linux"
MOCK
chmod +x "$fake_bin/uname"

output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/bash)
exit_code=$?

assert_exit "$exit_code" 0 "install exits 0"
assert_file_exists "$fake_home/.local/bin/helpme" "helpme binary downloaded"
assert_file_exists "$fake_home/.bashrc" ".bashrc created"
assert_file_contains "$fake_home/.bashrc" '.local/bin' ".bashrc contains .local/bin PATH"
assert_file_not_exists "$fake_home/.bash_profile" ".bash_profile not created"
echo ""

# ---------------------------------------------------------------
# Test 3: Bash on macOS with .bash_profile — modifies .bash_profile
# ---------------------------------------------------------------
echo "Test 3: Bash on macOS with .bash_profile modifies .bash_profile"
fake_home=$(make_fake_home)
fake_bin=$(make_mock_curl_bin)
# Mock uname to return Darwin
cat > "$fake_bin/uname" << 'MOCK'
#!/usr/bin/env bash
for arg in "$@"; do
  case "$arg" in
    -s) echo "Darwin"; exit 0 ;;
  esac
done
echo "Darwin"
MOCK
chmod +x "$fake_bin/uname"
# Pre-create .bash_profile
touch "$fake_home/.bash_profile"

output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/bash)
exit_code=$?

assert_exit "$exit_code" 0 "install exits 0"
assert_file_contains "$fake_home/.bash_profile" '.local/bin' ".bash_profile contains .local/bin PATH"
assert_file_not_contains "$fake_home/.bashrc" '.local/bin' ".bashrc not modified"
echo ""

# ---------------------------------------------------------------
# Test 4: Unknown shell with .zshrc present — falls back to .zshrc
# ---------------------------------------------------------------
echo "Test 4: Unknown shell with .zshrc present falls back to .zshrc"
fake_home=$(make_fake_home)
fake_bin=$(make_mock_curl_bin)
# Pre-create .zshrc
touch "$fake_home/.zshrc"

output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/unknown)
exit_code=$?

assert_exit "$exit_code" 0 "install exits 0"
assert_file_contains "$fake_home/.zshrc" '.local/bin' ".zshrc contains .local/bin PATH"
echo ""

# ---------------------------------------------------------------
# Test 5: Unknown shell, no RC files — install completes but
#          PATH is NOT added to any RC file (reveals current gap)
# ---------------------------------------------------------------
echo "Test 5: Unknown shell, no RC files — falls back to creating .bashrc"
fake_home=$(make_fake_home)
fake_bin=$(make_mock_curl_bin)

output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/unknown)
exit_code=$?

assert_exit "$exit_code" 0 "install exits 0"
assert_file_exists "$fake_home/.local/bin/helpme" "helpme binary downloaded"
assert_file_exists "$fake_home/.bashrc" ".bashrc created as fallback"
assert_file_contains "$fake_home/.bashrc" '.local/bin' ".bashrc contains .local/bin PATH"
echo ""

# ---------------------------------------------------------------
# Test 6: Idempotency — running install twice doesn't duplicate PATH
# ---------------------------------------------------------------
echo "Test 6: Idempotency — PATH line appears only once after two installs"
fake_home=$(make_fake_home)
fake_bin=$(make_mock_curl_bin)

run_install "$fake_home" "$fake_bin" SHELL=/bin/zsh >/dev/null 2>&1
run_install "$fake_home" "$fake_bin" SHELL=/bin/zsh >/dev/null 2>&1
exit_code=$?

assert_exit "$exit_code" 0 "second install exits 0"
occurrences=$(count_occurrences "$fake_home/.zshrc" '.local/bin')
if [[ "$occurrences" -eq 1 ]]; then
  pass "PATH line appears exactly once in .zshrc"
else
  fail "PATH line appears exactly once in .zshrc" "found $occurrences occurrences"
fi
echo ""

# ---------------------------------------------------------------
# Test 7: curl missing — exits 1 with error mentioning curl
# ---------------------------------------------------------------
echo "Test 7: curl missing — exits 1 with error message"
fake_home=$(make_fake_home)
no_curl_bin=$(mktemp -d)
CLEANUP_DIRS+=("$no_curl_bin")
# Symlink essential commands but NOT curl
for cmd in bash cat chmod echo grep head mkdir sed tail tr uname basename date printf; do
  src=$(command -v "$cmd" 2>/dev/null || true)
  if [[ -n "$src" ]]; then
    ln -sf "$src" "$no_curl_bin/$cmd"
  fi
done

set +e
output=$(env HOME="$fake_home" SHELL=/bin/zsh PATH="$no_curl_bin" bash -c '
  unset BASH_VERSION ZSH_VERSION
  eval "$(cat "$1")"
' _ "$INSTALL_SCRIPT" 2>&1)
exit_code=$?
set -e

assert_exit "$exit_code" 1 "install exits 1 when curl is missing"
assert_output_contains "$output" "curl" "error message mentions curl"
assert_file_not_exists "$fake_home/.local/bin/helpme" "helpme not installed when curl is missing"
echo ""

# ---------------------------------------------------------------
# Test 8: install telemetry — posts success event without affecting install
# ---------------------------------------------------------------
echo "Test 8: install telemetry posts success event"
fake_home=$(make_fake_home)
curl_log=$(mktemp)
body_log=$(mktemp)
CLEANUP_DIRS+=("$curl_log" "$body_log")
fake_bin=$(make_telemetry_curl_bin)

output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/zsh HELPME_TEST_CURL_LOG="$curl_log" HELPME_TEST_CURL_BODY_LOG="$body_log")
exit_code=$?

assert_exit "$exit_code" 0 "install exits 0 with telemetry enabled"
assert_output_contains "$(cat "$curl_log")" "/install" "telemetry POST targets /install"
assert_output_contains "$(cat "$body_log")" '"success":true' "telemetry marks success true"
assert_output_contains "$(cat "$body_log")" '"os":"' "telemetry includes os"
echo ""

# ---------------------------------------------------------------
# Test 9: telemetry failure — does not break install
# ---------------------------------------------------------------
echo "Test 9: telemetry failure does not break install"
fake_home=$(make_fake_home)
curl_log=$(mktemp)
CLEANUP_DIRS+=("$curl_log")
fake_bin=$(make_failing_telemetry_curl_bin)

output=$(run_install "$fake_home" "$fake_bin" SHELL=/bin/zsh HELPME_TEST_CURL_LOG="$curl_log")
exit_code=$?

assert_exit "$exit_code" 0 "install still exits 0 when telemetry fails"
assert_output_contains "$(cat "$curl_log")" "/install" "telemetry still attempted on failure"
assert_file_exists "$fake_home/.local/bin/helpme" "helpme still installed when telemetry fails"
echo ""

# --- Summary ---

echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
