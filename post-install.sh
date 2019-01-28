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
  # isntall packages if missing
  sudo pacman -S --needed \
    bat \
    docker \
    exa \
    fd \
    fish \
    # flatpak \
    # fzf \
    fzy \
    git \
    ripgrep \
    tmux \
    vim
elif [ "$distro" = 'Ubuntu' ]; then
  # sudo apt update
  # sudo apt install -y fish vim git ripgrep fd fzf docker
fi
exit1

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
    XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="~/.config"}
    curl https://git.io/fisher --create-dirs -sLo "$XDG_CONFIG_HOME"'/fish/functions/fisher.fish'
  fi

  # initialise fisher and run update packages
  fish -c fisher
else
  echo_err 'Fish shell is required to install user fish config. Skipping.'
fi

#######
# VIM #
#######

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
    mkdir -vp "$insiders_dir"/User/snippets
    if [ ! -d "$insiders_dir"/Dictionaries ]; then
      ln -vs "$hunspell_dir" "$insiders_dir"/Dictionaries
    fi
    if [ ! -f "$insiders_dir"/User/settings.json ]; then
      ln -vs "$code_dir"/User/settings.json "$insiders_dir"/User
    fi
    if [ ! -f "$insiders_dir"/User/keybindings.json ]; then
      ln -vs "$code_dir"/User/keybindings.json "$insiders_dir"/User
    fi
    if [ ! -d "$insiders_dir"/User/snippets ]; then
      ln -vs "$code_dir"/User/snippets "$insiders_dir"/User
    fi
  fi
fi

printf "%b" "${green}Finished successfully${reset}"
