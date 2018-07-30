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

set -o errtrace
trap 'echo_err "Error during install!"' ERR

# options
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
  #terraform
  #tmux
  #tslint
  vim
  vscode
  yarn
  #zsh
)
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
IGNORE_FILES="^((pre|post)-install|.*-entrypoint)\\.sh$"

################################################################################

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
dryrun=true
quiet=false
verbosity=-v

# colours
reset='\e[0m'
red_bold='\e[1;91m'
yellow_bold='\e[1;93m'
yellow='\e[0;33m'
blue='\e[0;94m'
cyan_bold='\e[1;96m'

# feedback utilities
echo_err() { echo -e "\\n${red_bold}❌ ERROR:${reset} $1${reset}" 1>&2; echo -e "\\a"; }
echo_warn() { echo -e "\\n${yellow_bold}🔶 WARNING:${reset} $1${reset}" 1>&2; echo -e "\\a"; }
echo_info() { [[ $quiet == true ]] || echo -e "$1${reset}" >&1; }

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

process_packages() {
  if [[ $dryrun = true ]]; then
    echo_warn "Doing dry run, check output then run ${yellow}$(basename "$0") -i"
  fi

  # do the actual linking for each package and run pre/post script hooks
  for package in "${PACKAGES[@]}"; do
    echo_info "\\n${blue}Installing ${cyan_bold}$package ${blue}package..."

    if [[ $dryrun = true ]]; then
      if [[ -f "$PACKAGES_DIR/$package/pre-install.sh" ]]; then
        source "$PACKAGES_DIR/$package/pre-install.sh"
      fi

      stow \
        $verbosity \
        --no \
        --dir="$PACKAGES_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"

      if [[ -f "$PACKAGES_DIR/$package/post-install.sh" ]]; then
        source "$PACKAGES_DIR/$package/post-install.sh"
      fi
    else
      if [[ -f "$PACKAGES_DIR/$package/pre-install.sh" ]]; then
        source "$PACKAGES_DIR/$package/pre-install.sh"
      fi

      stow \
        $verbosity \
        --dir="$PACKAGES_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"

      if [[ -f "$PACKAGES_DIR/$package/post-install.sh" ]]; then
        source "$PACKAGES_DIR/$package/post-install.sh"
      fi
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
      dryrun=false
      ;;
    q)
      quiet=true
      verbosity=''
      ;;
    v)
      verbosity=-vv
      ;;
  esac
done

shift $((OPTIND-1))

# handle manually specified package names
if [[ "$#" != 0 ]]; then
  PACKAGES=( "$@" )
fi

# run main function
process_packages
