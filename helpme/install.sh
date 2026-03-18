#!/usr/bin/env bash
# install-helpme.sh — one-line installer for the helpme CLI
# Usage: curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/install.sh | bash
{ # ensure the entire script is downloaded before execution begins
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
SCRIPT_URL="https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/helpme.sh"
SCRIPT_PATH="$BIN_DIR/helpme"
WORKER_BASE_URL="${HELPME_WORKER_URL:-https://helpme-worker.alejoacelas.workers.dev}"
INSTALL_URL="${HELPME_INSTALL_URL:-${WORKER_BASE_URL%/}/install}"

# Only use colors when connected to a terminal
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  GREEN='' YELLOW='' DIM='' RESET=''
fi

json_escape() {
  local s="${1:-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

send_install_telemetry() {
  local success="$1" step="$2" error_message="${3:-}"
  local os
  os=$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')
  local payload
  payload=$(printf '{"os":"%s","success":%s,"step":"%s","error":"%s"}' \
    "$(json_escape "$os")" \
    "$success" \
    "$(json_escape "$step")" \
    "$(json_escape "$error_message")")

  (
    set +e
    printf '%s' "$payload" | curl -sS --max-time 3 -X POST "$INSTALL_URL" \
      -H "Content-Type: application/json" \
      --data-binary @- >/dev/null 2>&1 || true
  ) &
}

echo ""
echo "Installing helpme..."

# 1. Check for curl (should always be there if they reached this script, but be safe)
if ! command -v curl &>/dev/null; then
  send_install_telemetry false "check_curl" "curl is required but not installed"
  echo -e "${YELLOW}Error: curl is required but not installed.${RESET}"
  echo "  On Mac: it's built in — something is very wrong."
  echo "  On Ubuntu/Debian: sudo apt install curl"
  echo "  On Fedora: sudo dnf install curl"
  exit 1
fi

# 2. Create bin directory
mkdir -p "$BIN_DIR"

# 3. Download helpme
if ! curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"; then
  send_install_telemetry false "download" "failed to download helpme script"
  echo ""
  echo -e "${YELLOW}Download failed.${RESET}"
  echo "  If you're on a corporate network, the download URL might be blocked."
  echo "  Ask a workshop organizer for the file directly."
  exit 1
fi

chmod +x "$SCRIPT_PATH"

# 4. Add to PATH if needed
add_to_path() {
  local rc_file="$1"
  local line='export PATH="$HOME/.local/bin:$PATH"'
  if [[ -f "$rc_file" ]] && grep -qF '.local/bin' "$rc_file" 2>/dev/null; then
    return 0  # already there
  fi
  echo "" >> "$rc_file"
  echo "# Added by helpme installer" >> "$rc_file"
  echo "$line" >> "$rc_file"
  return 1  # was added
}

PATH_ADDED=false
NEEDS_RELOAD=""

# Detect which shell RC file to use
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$(basename "${SHELL:-}")" == "zsh" ]]; then
  if add_to_path "$HOME/.zshrc"; then
    : # already in PATH
  else
    PATH_ADDED=true
    NEEDS_RELOAD="$HOME/.zshrc"
  fi
elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$(basename "${SHELL:-}")" == "bash" ]]; then
  # On macOS, bash reads .bash_profile for login shells (Terminal.app opens login shells)
  if [[ "$(uname -s)" == "Darwin" ]] && [[ -f "$HOME/.bash_profile" ]]; then
    if add_to_path "$HOME/.bash_profile"; then :; else PATH_ADDED=true; NEEDS_RELOAD="$HOME/.bash_profile"; fi
  else
    if add_to_path "$HOME/.bashrc"; then :; else PATH_ADDED=true; NEEDS_RELOAD="$HOME/.bashrc"; fi
  fi
else
  # Unknown shell — try existing RC files first, fall back to creating .bashrc
  found=false
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [[ -f "$rc" ]]; then
      if add_to_path "$rc"; then :; else PATH_ADDED=true; NEEDS_RELOAD="$rc"; fi
      found=true
      break
    fi
  done
  if [[ "$found" == "false" ]]; then
    if add_to_path "$HOME/.bashrc"; then :; else PATH_ADDED=true; NEEDS_RELOAD="$HOME/.bashrc"; fi
  fi
fi

# Also add to current session so it works immediately
export PATH="$BIN_DIR:$PATH"

# 5. Success message
echo ""
echo -e "${GREEN}✓ helpme installed successfully!${RESET}"
echo ""

if [[ "$PATH_ADDED" == "true" ]]; then
  echo -e "${DIM}~/.local/bin was added to your PATH.${RESET}"
  echo -e "${DIM}To use helpme right now, run:${RESET}"
  echo ""
  echo -e "  source $NEEDS_RELOAD"
  echo ""
  echo -e "${DIM}Or just open a new terminal window.${RESET}"
else
  echo -e "${DIM}Try it:${RESET}  helpme \"echo 'hello world'\""
fi
echo ""

send_install_telemetry true "complete" ""
} # end of full-download wrapper
