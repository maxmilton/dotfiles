#!/bin/bash

# check if Fisherman is installed
if [[ ! -f "$TARGET_DIR/.config/fish/functions/fisher.fish" ]]; then
  echo_warn "Fisherman is not installed, installing it now..."

  # install Fisher
  curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher
fi

# check fish shell is installed
if hash fish 2>/dev/null; then
  # install Fisherman plugins (always exit 0 to prevent stopping package install)
  echo_info "Installing Fisher theme and plugins."
  [[ $dryrun != true ]] && fish -c 'fisher MaxMilton/pure fzf z' || true

  # generate a compiled fish user config
  echo_info "Setting up fish user config."
  [[ $dryrun != true ]] && fish "$TARGET_DIR/.config/fish/onetime-config.fish"
else
  echo_err "Fish shell is required to install Fisher plugins. Skipping."
fi
