#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# check fish shell is installed
if hash fish 2>/dev/null; then
  # check if fisher is installed
  if ! fish -c 'functions -q fisher' 2>/dev/null; then
    echo_warn "Fisher not found, installing it now..."
    XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="~/.config"}
    $CMD curl https://git.io/fisher --create-dirs -sLo "$XDG_CONFIG_HOME/fish/functions/fisher.fish"
  fi

  echo_info "Installing Fisher packages"
  $CMD fish -c fisher

  # generate compiled fish user config
  echo_info "Setting up fish user config"
  $CMD fish "$TARGET_DIR/.config/fish/oneshot-config.fish"
else
  echo_err "Fish shell is required to install user fish config. Skipping."
fi
