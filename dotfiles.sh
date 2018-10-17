#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#
# INSTALL DOTFILES
#
# Creates symlinks to dotfiles in the user home directory. Running this script
# multiple times is completely fine to update or install additional packages.
#

# TODO: Need a way to automatically backup existing files instead of throwing
# an error and exiting -- maybe use something other than the --restow param?

# TODO: Add an example .stowrc or at least document its use

set -o errtrace # trap errors inside functions
trap 'echo_err "Error during install!"' ERR

# options
# TODO: Consider moving this array into a text file for easy user customisation
PACKAGES=(
  # disable a package by commenting it out
  bash
  curl
  fish
  git
  #hg
  htop
  #jsdoc
  #prettier
  ssh
  stow
  #terraform
  #tmux
  #tslint
  vim
  #vscode
  yarn
  #zsh
)
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
IGNORE_FILES="^((pre|post)-install|.*-entrypoint)\\.sh$"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

usage() {
  echo -e "
Usage: ${yellow}$(basename "$0") [OPTIONS] [PACKAGES]${reset}

Dotfiles package installer script.

OPTIONS:
  -h  Show this help text and exit.
  -i  Install packages (without this a dry run is performed).
  -q  Don't print info text to console.
  -v  Enable verbose output.

PACKAGES:
  The name/s of config packages to install. The package name is
  the same as the directory name. This is optional and if not
  specified the default set of packages will be installed.
  " >&1
}

################################################################################

# runtime settings
export cmd=
export dryrun=true
export quiet=false
export verbosity=-v

# colours
export reset='\x1B[0m'
export cyan_bold='\x1B[1;96m'
export green='\x1B[0;92m'
export red_bold='\x1B[1;91m'
export yellow_bold='\x1B[1;93m'
export blue='\x1B[0;94m'
export yellow='\x1B[0;33m'

# feedback utilities
echo_err() { local IFS=' '; printf "\\a\\n%b❌ ERROR:%b %s%b\\n" "$red_bold" "$reset" "$*" "$reset" 1>&2; }
echo_warn() { local IFS=' '; printf "\\a\\n%b🔶 WARNING:%b %s%b\\n" "$yellow_bold" "$reset" "$*" "$reset" 1>&2; }
echo_info() { local IFS=' '; [[ $quiet == true ]] || printf "%b\\n" "$*$reset" >&1; }
echo_dryrun() { local IFS=' '; printf "%bDRY RUN:%b %s\\n" "$green" "$reset" "$*"; }

# check GNU Stow is installed
if ! hash stow 2>/dev/null; then
  echo_err "GNU Stow is required but not installed. Aborting."
  exit 1
fi

# variables for use in install scripts
OS=$(uname)
DISTRO='Not Linux'

if [[ "$OS" = 'Linux' ]]; then
  DISTRO=$(awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')
fi

export OS
export DISTRO

process_packages() {
  if [[ $dryrun = true ]]; then
    echo_warn "Doing dry run, check output then run ${yellow}$(basename "$0") -i"
  fi

  # do the actual linking for each package and run pre/post script hooks
  for package in "${PACKAGES[@]}"; do
    echo_info "\\n${blue}Installing ${cyan_bold}$package ${blue}package..."

    if [[ -f "$PACKAGES_DIR/$package/pre-install.sh" ]]; then
      # shellcheck source=/dev/null
      source "$PACKAGES_DIR/$package/pre-install.sh"
    fi

    if [[ $dryrun = true ]]; then
      stow \
        $verbosity \
        --no \
        --dir="$PACKAGES_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"
    else
      stow \
        $verbosity \
        --dir="$PACKAGES_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"
    fi

    if [[ -f "$PACKAGES_DIR/$package/post-install.sh" ]]; then
      # shellcheck source=/dev/null
      source "$PACKAGES_DIR/$package/post-install.sh"
    fi
  done
}

# reset in case getopts has been used previously in the shell
OPTIND=1

# parse options
while getopts "h?iqv" opt; do
  case "$opt" in
    h|\?)
      usage
      exit 0
      ;;
    i)
      export dryrun=false
      ;;
    q)
      export quiet=true
      export verbosity=''
      ;;
    v)
      export verbosity=-vv
      ;;
  esac
done

shift $((OPTIND-1))

# handle manually specified package names
if [[ "$#" != 0 ]]; then
  PACKAGES=("$@")
fi

if [[ $dryrun = true ]]; then
  export cmd=echo_dryrun
fi

# run main function
process_packages
