#!/bin/bash

# TODO: Change this once the new dictionary project is ready.
# DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/packages/dictionary"}
DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/hunspell-dictionary"}

if [[ $dryrun = true ]]; then
  echo_info "mkdir -v -p \"$TARGET_DIR/.config/Code/User\""

  # dictionaries
  if [[ ! -d "$TARGET_DIR/.config/Code/Dictionaries" ]]; then
    echo_info "mkdir -v -p /usr/share/hunspell"
    echo_info "ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell"
    echo_info "ln -v -s /usr/share/hunspell \"$TARGET_DIR/.config/Code/Dictionaries\""
  fi
else
  mkdir -v -p "$TARGET_DIR/.config/Code/User"

  # dictionaries
  if [[ ! -d "$TARGET_DIR/.config/Code/Dictionaries" ]]; then
    mkdir -v -p /usr/share/hunspell
    ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell
    ln -v -s /usr/share/hunspell "$TARGET_DIR/.config/Code/Dictionaries"
  fi
fi
