#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# TODO: Change this once the new dictionary project is ready.
# DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/packages/dictionary"}
DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/hunspell-dictionary"}

if [[ "$OS" != 'Darwin' ]]; then
  $cmd mkdir -v -p "$TARGET_DIR/.config/Code/User"

  # dictionaries
  if [[ ! -d "$TARGET_DIR/.config/Code/Dictionaries" ]]; then
    if [[ ! -d "/usr/share/hunspell" ]]; then
      if [[ $DISTRO = "Fedora" ]]; then
        $cmd sudo ln -v -s /usr/share/myspell /usr/share/hunspell
      else
        $cmd sudo mkdir -v -p /usr/share/hunspell
      fi
    fi
    $cmd sudo ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell
    $cmd sudo ln -v -s /usr/share/hunspell "$TARGET_DIR/.config/Code/Dictionaries"
  fi
else
  echo_warn "You need to manually set up VS Code directories on macOS."
fi
