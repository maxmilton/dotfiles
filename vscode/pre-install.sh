#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# TODO: Change this once the new dictionary project is ready.
# DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR""/Development/packages/dictionary"}
DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR""/Development/hunspell-dictionary"}

if [[ "$OS" != 'Darwin' ]]; then
  CODE_DIR="$TARGET_DIR"/.config/Code
  INSIDERS_DIR="$TARGET_DIR""/.config/Code - Insiders"

  $cmd mkdir $verbosity -p "$CODE_DIR"/User/snippets

  # dictionaries
  if [[ ! -d "$CODE_DIR/Dictionaries" ]]; then
    if [[ ! -d "/usr/share/hunspell" ]]; then
      if [[ $DISTRO = "Fedora" ]]; then
        $cmd sudo ln $verbosity -sf /usr/share/myspell /usr/share/hunspell
      else
        $cmd sudo mkdir $verbosity -p /usr/share/hunspell
      fi
    fi

    if [[ ! -d "/usr/share/hunspell" ]]; then
      $cmd sudo ln -i $verbosity -sf "$DICTIONARY_DIR"/*.{dic,aff} /usr/share/hunspell
    fi
    if [[ ! -d "$CODE_DIR""/Dictionaries" ]]; then
      $cmd sudo ln $verbosity -sf /usr/share/hunspell "$CODE_DIR"/Dictionaries
    fi
  fi

  # VS Code insiders
  if type code-insiders; then
    $cmd mkdir $verbosity -p "$INSIDERS_DIR"/User/snippets
    if [[ ! -d "$INSIDERS_DIR""/Dictionaries" ]]; then
      $cmd ln $verbosity -sf /usr/share/hunspell "$INSIDERS_DIR"/Dictionaries
    fi
    $cmd ln $verbosity -sf "$CODE_DIR"/User/settings.json "$INSIDERS_DIR"/User
    $cmd ln $verbosity -sf "$CODE_DIR"/User/keybindings.json "$INSIDERS_DIR"/User
    $cmd ln $verbosity -sf "$CODE_DIR"/User/snippets/*.json "$INSIDERS_DIR"/User/snippets
  fi
else
  echo_warn "You need to manually set up VS Code directories on macOS."
fi
