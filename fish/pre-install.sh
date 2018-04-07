#!/bin/bash

if [[ $dryrun = true ]]; then
  # dry run
  echo_info "mkdir -v -p \"$TARGET_DIR/.config/fish/functions\""
else
  mkdir -v -p "$TARGET_DIR/.config/fish/functions"
fi
