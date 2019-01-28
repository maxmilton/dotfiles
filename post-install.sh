#!/bin/sh
set -euf

# colours
reset='\x1B[0m'
green='\x1B[0;92m'
red='\x1B[1;91m'
yellow='\x1B[1;93m'

# feedback utils
echo_err() { printf "%b" "\\n${red}ERROR:${reset} ${*}${reset}" 1>&2; }
echo_warn() { printf "%b" "\\n${yellow}WARNING:${reset} ${*}${reset}" 1>&2; }

# notify error on non-zero exit codes
handle_err () { [ $? -eq 0 ] && exit; echo_err 'Install error!'; }
trap handle_err EXIT

# initialise vars
target_dir="$HOME"
os=$(uname)
distro='Not Linux'

if [ "$os" = Linux ]; then
  distro=$(awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')
fi

# check chezmoi is installed
if ! hash chezmoi 2>/dev/null; then
  echo_err 'chezmoi is required but not installed. Aborting.'
  exit 1
fi

########
# Fish #
########

# check fish shell is installed
if hash fish 2>/dev/null; then
  # check fisher is installed
  if ! fish -c 'functions -q fisher' 2>/dev/null; then
    echo_warn "Fisher not found, downloading..."
    XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="~/.config"}
    curl https://git.io/fisher --create-dirs -sLo "$XDG_CONFIG_HOME"'/fish/functions/fisher.fish'
  fi

  fish -c fisher

  # generate compiled fish user config
  fish "$target_dir"/.config/fish/oneshot-config.fish
else
  echo_err 'Fish shell is required to install user fish config. Skipping.'
fi

#######
# VIM #
#######

mkdir -v -p "$target_dir"/.vim/backup
mkdir -v -p "$target_dir"/.vim/swap
mkdir -v -p "$target_dir"/.vim/undo

###########
# VS Code #
###########

if [ "$os" = Darwin ]; then
  echo_warn 'You need to manually set up VS Code directories on macOS.'
else
  hunspell_dir=/usr/share/hunspell
  dictionary_dir="$target_dir"/Projects/packages/dictionary
  code_dir="$target_dir"/.config/Code
  insiders_dir="$target_dir"'/.config/Code - Insiders'

  mkdir -v -p "$code_dir"/User/snippets

  # dictionaries
  if [ ! -d "$code_dir"/Dictionaries ]; then
    if [ ! -d "$hunspell_dir" ]; then
      if [ "$distro" = Fedora ]; then
        sudo ln -v -s /usr/share/myspell "$hunspell_dir"
      else
        sudo mkdir -v -p "$hunspell_dir"
      fi
    fi

    if [ ! -d "$hunspell_dir" ]; then
      sudo ln -i -v -sf "$dictionary_dir"/en_GB.dic "$hunspell_dir"
      sudo ln -i -v -sf "$dictionary_dir"/en_GB.aff "$hunspell_dir"
    fi
    if [ ! -d "$code_dir"/Dictionaries ]; then
      sudo ln -v -s "$hunspell_dir" "$code_dir"/Dictionaries
    fi
  fi

  # VS Code insiders
  if type code-insiders > /dev/null 2>&1; then
    mkdir -v -p "$insiders_dir"/User/snippets
    if [ ! -d "$insiders_dir"/Dictionaries ]; then
      ln -v -s "$hunspell_dir" "$insiders_dir"/Dictionaries
    fi
    if [ ! -d "$insiders_dir"/User/settings.json ]; then
      ln -v -s "$code_dir"/User/settings.json "$insiders_dir"/User
    fi
    if [ ! -d "$insiders_dir"/User/keybindings.json ]; then
      ln -v -s "$code_dir"/User/keybindings.json "$insiders_dir"/User
    fi
    if [ ! -d "$insiders_dir"/User/snippets ]; then
      ln -v -s "$code_dir"/User/snippets "$insiders_dir"/User
    fi
  fi
fi

printf "%b" "${green}Finished successfully${reset}"
