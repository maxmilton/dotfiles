#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# check if Fisherman is installed
if [[ ! -f "$TARGET_DIR/.config/fish/functions/fisher.fish" ]]; then
  echo_warn "Fisher is not installed, installing it now..."

  # install Fisher
  $cmd curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fi

# check fish shell is installed
if hash fish 2>/dev/null; then
  # install Fisherman plugins (always exit 0 to prevent stopping package install)
  echo_info "Installing Fisher theme and plugins."
  $cmd fish -c 'fisher add MaxMilton/pure jethrokuan/fzf jethrokuan/z' || true

  # generate a compiled fish user config
  echo_info "Setting up fish user config."
  $cmd fish "$TARGET_DIR/.config/fish/onetime-config.fish"
else
  echo_err "Fish shell is required to install Fisher plugins. Skipping."
fi
