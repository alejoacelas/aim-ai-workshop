#!/bin/bash
# Install Homebrew and automatically add it to PATH.
# Designed for workshop participants who shouldn't have to copy-paste
# the "Next steps" commands manually.

set -e

# Run the official Homebrew installer (non-interactive)
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Determine the correct prefix
if [[ "$(uname -m)" == "arm64" ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
else
  HOMEBREW_PREFIX="/usr/local"
fi

# If brew is already on PATH, we're done
if command -v brew &>/dev/null; then
  echo "Homebrew is installed and on your PATH. You're all set!"
  exit 0
fi

# Determine the shell config file
case "${SHELL}" in
  */bash*)
    shell_rcfile="${HOME}/.bash_profile"
    shellenv_suffix=" bash"
    ;;
  */zsh*)
    shell_rcfile="${ZDOTDIR:-"${HOME}"}/.zprofile"
    shellenv_suffix=" zsh"
    ;;
  */fish*)
    shell_rcfile="${HOME}/.config/fish/config.fish"
    shellenv_suffix=" fish"
    ;;
  *)
    shell_rcfile="${ENV:-"${HOME}/.profile"}"
    shellenv_suffix=""
    ;;
esac

# Add brew shellenv to the shell config (if not already there)
if ! grep -qs "eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv" "${shell_rcfile}"; then
  echo >> "${shell_rcfile}"
  echo "eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv${shellenv_suffix})\"" >> "${shell_rcfile}"
  echo "Added Homebrew to ${shell_rcfile}"
fi

# Activate for the current shell
eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv${shellenv_suffix})"

echo "Homebrew is installed and on your PATH. You're all set!"
