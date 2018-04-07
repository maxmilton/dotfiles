#!/bin/bash

if [[ $dryrun = true ]]; then
  # dry run
  echo_info "mkdir -v -p \"$TARGET_DIR/.oh-my-zsh/themes\""
else
  mkdir -v -p "$TARGET_DIR/.oh-my-zsh/themes"

  # check if Oh My Zsh is installed
  if [[ ! -d "$TARGET_DIR/.oh-my-zsh" ]]; then
    echo_warn "Oh My Zsh is not installed, get it from https://goo.gl/fMX6bC"
  fi
fi
