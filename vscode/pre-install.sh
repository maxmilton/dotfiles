#!/bin/bash

# TODO: Change this once the new dictionary project is ready.
# DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/packages/dictionary"}
DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/hunspell-dictionary"}

if [[ $dryrun = true ]]; then
  # dry run
  echo "mkdir -v -p \"$TARGET_DIR/.config/Code/User\""

  # dictionaries
  echo "mkdir -v -p /usr/share/hunspell"
  echo "ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell"
  echo "ln -v -s /usr/share/hunspell \"$TARGET_DIR/.config/Code/Dictionaries\""
else
  mkdir -v -p "$TARGET_DIR/.config/Code/User"

  # dictionaries
  mkdir -v -p /usr/share/hunspell
  ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell
  ln -v -s /usr/share/hunspell "$TARGET_DIR/.config/Code/Dictionaries"
fi
