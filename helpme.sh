#!/usr/bin/env bash
# helpme — wrap any command, get plain-English help if it fails
# Usage: helpme -- <command> [args...]
# No dependencies beyond bash and curl.

# Require bash (process substitution doesn't work in sh/dash)
if [ -z "$BASH_VERSION" ]; then
  echo "helpme requires bash. Run: bash $(command -v helpme || echo helpme)" >&2
  exit 1
fi

set -uo pipefail

WORKER_URL="https://helpme-worker.alejoacelas.workers.dev"
LOG_DIR="$HOME/.helpme"
LOG_FILE="$LOG_DIR/log.jsonl"
SESSION_ID="${HELPME_SESSION:-$(date +%s)-$$}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

# Parse args: skip leading "--" if present
if [[ "${1:-}" == "--" ]]; then
  shift
fi

if [[ $# -eq 0 ]]; then
  echo "Usage: helpme -- <command> [args...]"
  echo "Example: helpme -- brew install git"
  exit 1
fi

COMMAND="$*"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Create temp files for capturing output
STDOUT_FILE=$(mktemp)
STDERR_FILE=$(mktemp)
trap 'rm -f "$STDOUT_FILE" "$STDERR_FILE"' EXIT

# Run the command, streaming output to terminal AND capturing it
set +e
bash -c "$COMMAND" > >(tee "$STDOUT_FILE") 2> >(tee "$STDERR_FILE" >&2)
EXIT_CODE=$?
set -e

# Small delay to let tee finish flushing
sleep 0.1

STDOUT=$(cat "$STDOUT_FILE" 2>/dev/null || true)
STDERR=$(cat "$STDERR_FILE" 2>/dev/null || true)

# Detect OS and shell
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
SHELL_NAME=$(basename "${SHELL:-unknown}" 2>/dev/null || echo "unknown")

# --- JSON helpers (no jq dependency) ---

# Escape a string for safe embedding in JSON
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"    # backslash
  s="${s//\"/\\\"}"    # double quote
  s="${s//$'\n'/\\n}"  # newline
  s="${s//$'\r'/\\r}"  # carriage return
  s="${s//$'\t'/\\t}"  # tab
  printf '%s' "$s"
}

# Truncate a string to N bytes (safe for the shell, avoids massive payloads)
truncate() {
  printf '%.'"${2:-2000}"'s' "$1"
}

# Build a JSON log entry
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)
LOG_ENTRY=$(printf '{"timestamp":"%s","command":"%s","stdout":"%s","stderr":"%s","exit_code":%d,"os":"%s","shell":"%s"}' \
  "$(json_escape "$TIMESTAMP")" \
  "$(json_escape "$COMMAND")" \
  "$(json_escape "$(truncate "$STDOUT" 2000)")" \
  "$(json_escape "$(truncate "$STDERR" 2000)")" \
  "$EXIT_CODE" \
  "$(json_escape "$OS")" \
  "$(json_escape "$SHELL_NAME")")

echo "$LOG_ENTRY" >> "$LOG_FILE" 2>/dev/null || true

# Read recent log history (last 5 entries, excluding current)
LOG_HISTORY="[]"
if [[ -f "$LOG_FILE" ]]; then
  # Read last 6 lines, drop the last one (current entry), wrap in JSON array
  HISTORY_LINES=$(tail -6 "$LOG_FILE" | head -5)
  if [[ -n "$HISTORY_LINES" ]]; then
    LOG_HISTORY="[$(echo "$HISTORY_LINES" | paste -sd',' -)]"
  fi
fi

# Build the request payload
PAYLOAD=$(printf '{"command":"%s","stdout":"%s","stderr":"%s","exit_code":%d,"os":"%s","shell":"%s","session_id":"%s","log_history":%s}' \
  "$(json_escape "$COMMAND")" \
  "$(json_escape "$(truncate "$STDOUT" 3000)")" \
  "$(json_escape "$(truncate "$STDERR" 3000)")" \
  "$EXIT_CODE" \
  "$(json_escape "$OS")" \
  "$(json_escape "$SHELL_NAME")" \
  "$(json_escape "$SESSION_ID")" \
  "$LOG_HISTORY")

# POST to worker
RESPONSE=$(curl -s --max-time 15 -X POST "$WORKER_URL/analyze" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" 2>/dev/null || true)

if [[ -z "$RESPONSE" ]]; then
  if [[ $EXIT_CODE -ne 0 ]]; then
    echo ""
    echo -e "${YELLOW}The command failed (exit code $EXIT_CODE) but couldn't reach the help service.${RESET}"
    echo -e "${DIM}Check your internet connection and try again.${RESET}"
  fi
  exit $EXIT_CODE
fi

# --- Parse JSON response without jq ---
# Extract simple string/bool fields using python3 if available, else grep

parse_json_field() {
  local json="$1" field="$2"
  # Try python3 first (available on macOS always, most Linux)
  if command -v python3 &>/dev/null; then
    python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    v = d.get('$field', '')
    if isinstance(v, list):
        print('\n'.join(str(x) for x in v))
    elif isinstance(v, bool):
        print(str(v).lower())
    else:
        print(v)
except: pass
" <<< "$json"
    return
  fi
  # Fallback: basic grep extraction (handles simple cases)
  echo "$json" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*"'"$field"'"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/'
}

OK=$(parse_json_field "$RESPONSE" "ok")
EXPLANATION=$(parse_json_field "$RESPONSE" "explanation")
FIX_COMMANDS=$(parse_json_field "$RESPONSE" "fix_commands")

if [[ "$OK" == "true" && -n "$EXPLANATION" ]]; then
  echo ""
  echo -e "${GREEN}✓ $EXPLANATION${RESET}"
elif [[ "$OK" == "false" && -n "$EXPLANATION" ]]; then
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${YELLOW}$EXPLANATION${RESET}"

  if [[ -n "$FIX_COMMANDS" ]]; then
    echo ""
    echo -e "${DIM}Suggested fix:${RESET}"
    while IFS= read -r cmd; do
      [[ -z "$cmd" ]] && continue
      echo -e "  ${CYAN}\$ $cmd${RESET}"
    done <<< "$FIX_COMMANDS"

    echo ""
    read -r -p "Run these commands? [Y/n] " confirm </dev/tty
    confirm=${confirm:-Y}
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      while IFS= read -r cmd; do
        [[ -z "$cmd" ]] && continue
        echo -e "${DIM}\$ $cmd${RESET}"
        bash -c "$cmd"
      done <<< "$FIX_COMMANDS"
    fi
  fi
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
fi

exit $EXIT_CODE
