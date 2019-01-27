# fish pre
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

$CMD mkdir "$V" -p "$TARGET_DIR"'/.config/fish/functions'

# fish post
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

# vim pre
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

$CMD mkdir "$V" -p "$TARGET_DIR"/.vim/{backup,swap,undo}

# vscode pre
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# TODO: Change this once the new dictionary project is ready.
# DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR"'/Development/packages/dictionary'}
DICTIONARY_DIR=${DICTIONARY_DIR:-"$TARGET_DIR"'/Development/hunspell-dictionary'}

if [[ "$OS" != 'Darwin' ]]; then
  CODE_DIR="$TARGET_DIR"'/.config/Code'
  INSIDERS_DIR="$TARGET_DIR"'/.config/Code - Insiders'

  $CMD mkdir "$V" -p "$CODE_DIR"'/User/snippets'

  # dictionaries
  if [[ ! -d "$CODE_DIR/Dictionaries" ]]; then
    if [[ ! -d "/usr/share/hunspell" ]]; then
      if [[ "$DISTRO" = 'Fedora' ]]; then
        $CMD sudo ln "$V" -sf /usr/share/myspell /usr/share/hunspell
      else
        $CMD sudo mkdir "$V" -p /usr/share/hunspell
      fi
    fi

    if [[ ! -d "/usr/share/hunspell" ]]; then
      $CMD sudo ln -i "$V" -sf "$DICTIONARY_DIR"/*.{dic,aff} /usr/share/hunspell
    fi
    if [[ ! -d "$CODE_DIR""/Dictionaries" ]]; then
      $CMD sudo ln "$V" -sf /usr/share/hunspell "$CODE_DIR"'/Dictionaries'
    fi
  fi

  # VS Code insiders
  if type code-insiders; then
    $CMD mkdir "$V" -p "$INSIDERS_DIR"'/User/snippets'
    if [[ ! -d "$INSIDERS_DIR"'/Dictionaries' ]]; then
      $CMD ln "$V" -sf /usr/share/hunspell "$INSIDERS_DIR"'/Dictionaries'
    fi
    $CMD ln "$V" -sf "$CODE_DIR"'/User/settings.json' "$INSIDERS_DIR"'/User'
    $CMD ln "$V" -sf "$CODE_DIR"'/User/keybindings.json' "$INSIDERS_DIR"'/User'
    $CMD ln "$V" -sf "$CODE_DIR""/User/snippets/*.json" "$INSIDERS_DIR"'/User/snippets'
  fi
else
  echo_warn "You need to manually set up VS Code directories on macOS."
fi

# yarn pre
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

$CMD mkdir "$V" -p "$TARGET_DIR"'/.config/yarn/global'
