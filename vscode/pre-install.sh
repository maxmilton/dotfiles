#!/bin/bash

# TODO: Change this once the new dictionary project is ready.
# DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/packages/dictionary"}
DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR/Development/hunspell-dictionary"}

if [[ $dryrun = true ]]; then
  echo_info "mkdir -v -p \"$TARGET_DIR/.config/Code/User\""

  # dictionaries
  if [[ ! -d "$TARGET_DIR/.config/Code/Dictionaries" ]]; then
    if [[ ! -d "/usr/share/hunspell" ]]; then
      if [[ $DISTRO = "Fedora" ]]; then
        echo_info "sudo ln -v -s /usr/share/myspell /usr/share/hunspell"
      else
        echo_info "sudo mkdir -v -p /usr/share/hunspell"
      fi
    fi
    echo_info "mkdir -v -p /usr/share/hunspell"
    echo_info "sudo ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell"
    echo_info "sudo ln -v -s /usr/share/hunspell \"$TARGET_DIR/.config/Code/Dictionaries\""
  fi
else
  mkdir -v -p "$TARGET_DIR/.config/Code/User"

  # dictionaries
  if [[ ! -d "$TARGET_DIR/.config/Code/Dictionaries" ]]; then
    if [[ ! -d "/usr/share/hunspell" ]]; then
      if [[ $DISTRO = "Fedora" ]]; then
        sudo ln -v -s /usr/share/myspell /usr/share/hunspell
      else
        sudo mkdir -v -p /usr/share/hunspell
      fi
    fi
    sudo ln -i -v -s $DICTIONARY_DIR/*.{dic,aff} /usr/share/hunspell
    sudo ln -v -s /usr/share/hunspell "$TARGET_DIR/.config/Code/Dictionaries"
  fi
fi
