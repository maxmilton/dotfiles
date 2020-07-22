#!/bin/sh
set -euf

# directory of this script
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# colours
RESET='\x1B[0m'
GREEN='\x1B[0;92m'
RED='\x1B[1;91m'
YELLOW='\x1B[1;93m'

# feedback utils
echo_err() { printf "%b" "\\n${RED}ERROR:${RESET} ${*}${RESET}" 1>&2; }
echo_warn() { printf "%b" "\\n${YELLOW}WARNING:${RESET} ${*}${RESET}" 1>&2; }

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

###################
# System packages #
###################

# TODO: Install themer packages + set up gen output

# Install common system packages

echo OS $os
echo DISTRO $distro

if [ "$distro" = 'Arch Linux' ]; then
  # update package database
  sudo pacman -Sy
  # install packages if missing
  sudo pacman -S --needed \
    bat \
    docker \
    exa \
    fd \
    fish \
    fzf \
    fzy \
    git \
    ripgrep \
    neovim \
    # flatpak \
    #tmux \
elif [ "$distro" = 'Ubuntu' ]; then
  sudo apt update
  sudo apt install -y fish vim git ripgrep fd fzf docker
fi

############
# Terminal #
############

# install gnome terminal theme to profile named "Default" (needs to be manually named first!)
$DIR/gnome-terminal-theme.sh Default

########
# Fish #
########

# check fish shell is installed
if hash fish 2>/dev/null; then
  # generate compiled fish user config
  fish "$target_dir"/.config/fish/oneshot-config.fish

  # check fisher is installed
  if ! fish -c 'functions -q fisher' 2>/dev/null; then
    echo_warn "Fisher not found, downloading..."
    XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="${target_dir}/.config"}
    curl https://git.io/fisher --create-dirs -sLo "$XDG_CONFIG_HOME"'/fish/functions/fisher.fish'
  fi

  # initialise fisher and run update packages
  fish -c fisher
else
  echo_err 'Fish shell is required to install user fish config. Skipping.'
fi

##########
# Neovim #
##########

mkdir -vp "$target_dir"/.vim/backup
mkdir -vp "$target_dir"/.vim/swap
mkdir -vp "$target_dir"/.vim/undo

# TODO: Automatically run `PlugInstall` in vim

###########
# VS Code #
###########

if [ "$os" = Darwin ]; then
  echo_warn 'You need to manually set up VS Code directories on macOS.'
else
  hunspell_dir=/usr/share/hunspell
  dictionary_dir="$target_dir"/Projects/packages/dictionary/dist
  code_dir="$target_dir"/.config/Code
  insiders_dir="$target_dir"'/.config/Code - Insiders'
  oss_dir="$target_dir"'/.config/Code - OSS'

  mkdir -vp "$code_dir"/User/snippets

  # dictionaries
  if [ ! -d "$code_dir"/Dictionaries ]; then
    if [ ! -d "$hunspell_dir" ]; then
      if [ "$distro" = Fedora ]; then
        sudo ln -vs /usr/share/myspell "$hunspell_dir"
      else
        sudo mkdir -vp "$hunspell_dir"
      fi
    fi

    if [ ! -d "$hunspell_dir" ]; then
      sudo ln -i -vsf "$dictionary_dir"/en_GB.dic "$hunspell_dir"
      sudo ln -i -vsf "$dictionary_dir"/en_GB.aff "$hunspell_dir"
    fi
    if [ ! -d "$code_dir"/Dictionaries ]; then
      sudo ln -vs "$hunspell_dir" "$code_dir"/Dictionaries
    fi
  fi

  # VS Code insiders
  if type code-insiders > /dev/null 2>&1; then
    if [ ! -d "$insiders_dir"/Dictionaries ]; then
      ln -vsr "$hunspell_dir" "$insiders_dir"/Dictionaries
    fi
    if [ ! -f "$insiders_dir"/User/settings.json ]; then
      ln -vsr "$code_dir"/User/settings.json "$insiders_dir"/User
    fi
    if [ ! -f "$insiders_dir"/User/keybindings.json ]; then
      ln -vsr "$code_dir"/User/keybindings.json "$insiders_dir"/User
    fi
    if [ ! -d "$insiders_dir"/User/snippets ]; then
      ln -vsr "$code_dir"/User/snippets "$insiders_dir"/User/
    fi
  fi

  # VS Code OSS
  if type code > /dev/null 2>&1; then
    if [ -d "$oss_dir" ]; then
      if [ ! -d "$oss_dir"/Dictionaries ]; then
        ln -vsr "$hunspell_dir" "$oss_dir"/Dictionaries
      fi
      if [ ! -f "$oss_dir"/User/settings.json ]; then
        ln -vsr "$code_dir"/User/settings.json "$oss_dir"/User
      fi
      if [ ! -f "$oss_dir"/User/keybindings.json ]; then
        ln -vsr "$code_dir"/User/keybindings.json "$oss_dir"/User
      fi
      if [ ! -d "$oss_dir"/User/snippets ]; then
        ln -vsr "$code_dir"/User/snippets "$oss_dir"/User/
      fi
    fi
  fi
fi

printf "%b" "${GREEN}Finished successfully${RESET}"

########
# Yarn #
########

mkdir -vp "$target_dir"/.config/yarn/mirror
