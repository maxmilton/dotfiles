#!/bin/bash

#
# INSTALL DOTFILES
#
# Creates symlinks to dotfiles in the user home directory. Running this script
# multiple times is completely fine to update or install additional packages.
#

# TODO: Need a way to automatically backup existing files instead of throwing
# an error and exiting -- maybe use something other than the --restow param?

set -eo errtrace
trap 'echo_err "Error during install!"' ERR

# options
PACKAGES=(
  # disable a package by commenting it out
  bash
  fish
  git
  #hg
  htop
  jsdoc
  prettier
  terraform
  tmux
  tslint
  vim
  vscode
  yarn
  zsh
)
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
IGNORE_FILES="^(?:pre|post)-install\.sh"

################################################################################

usage() {
  echo -e "
Usage: \033[1;33m$(basename "$0") [OPTIONS]\033[0m

Dotfiles package installer script.

OPTIONS:
  -h  Show this help text and exit.
  -i  Install packages (without this a dry run is performed).
  -q  Don't print info text to console.
  -v  Enable verbose output.
  " >&1
}

# runtime settings
dryrun=true
quiet=false
verbosity=-v

# feedback utilities
echo_err() { echo -e "\n\e[1;91m❌ ERROR:\e[0m $1\e[0m" 1>&2; echo -e "\a"; }
echo_warn() { echo -e "\n\e[1;93m🔶 WARNING:\e[0m $1\e[0m" 1>&2; echo -e "\a"; }
echo_info() { [[ $quiet == true ]] || echo -e "$1\e[0m" >&1; }

# check GNU Stow is installed
if ! hash stow 2>/dev/null; then
  echo_err "GNU Stow is required but not installed. Aborting."
  exit 1
fi

process_packages() {
  if [[ $dryrun = true ]]; then
    echo_warn "Doing dry run, check output then run \e[1;33m$(basename "$0") -i"
  fi

  # do the actual linking for each package and run pre/post script hooks
  for package in "${PACKAGES[@]}"; do
    echo_info "\n\e[94mInstalling \e[1;96m$package \e[0;94mpackage..."

    if [[ $dryrun = true ]]; then
      [[ -f "$PACKAGES_DIR/$package/pre-install.sh" ]] \
        && source "$PACKAGES_DIR/$package/pre-install.sh" || true

      stow \
        $verbosity \
        --no \
        --dir="$PACKAGES_DIR" \
        --target="$TARGET_DIR" \
        --ignore=$IGNORE_FILES \
        --restow \
        "$package"

      [[ -f "$PACKAGES_DIR/$package/post-install.sh" ]] \
        && source "$PACKAGES_DIR/$package/post-install.sh" || true
    else
      [[ -f "$PACKAGES_DIR/$package/pre-install.sh" ]] \
        && source "$PACKAGES_DIR/$package/pre-install.sh" || true

      stow \
        $verbosity \
        --dir="$PACKAGES_DIR" \
        --target="$TARGET_DIR" \
        --ignore=$IGNORE_FILES \
        --restow \
        "$package"

      [[ -f "$PACKAGES_DIR/$package/post-install.sh" ]] \
        && source "$PACKAGES_DIR/$package/post-install.sh" || true
    fi
  done
}

# reset in case getopts has been used previously in the shell
OPTIND=1

# parse options
while getopts "h?iqv" opt; do
  case "$opt" in
    h |\? )
      usage
      exit 0
      ;;
    i )
      dryrun=false
      ;;
    q )
      quiet=true
      verbosity=''
      ;;
    v )
      verbosity=-vv
      ;;
  esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

# run main function
process_packages
