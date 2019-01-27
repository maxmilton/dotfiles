#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

$CMD mkdir "$V" -p "$TARGET_DIR"'/.oh-my-zsh/themes'

# check if Oh My Zsh is installed
if [[ ! -d "$TARGET_DIR"'/.oh-my-zsh' ]]; then
  echo_warn "Oh My Zsh is not installed, get it from https://goo.gl/fMX6bC"
fi
