#!/bin/bash

#
# INSTALL DOTFILES
#
# Creates symlinks to dotfiles in the user home directory. Running this script
# multiple times is completely fine to update or install additional packages.
#

# TODO: Need a way to automatically backup existing files instead of throwing
# an error and exiting -- maybe use something other than the --restow param?

# TODO: Implement a way to create directories per package -- otherwise gnu stow
# will create symlinks for the whole dir if it doesn't exist, which is often
# undesireable.

set -e

# options
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
PACKAGES=(
  # disable a package by commenting it out
  bash
  fish
  git
  #hg
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

# settings
dryrun=true
verbosity=v

# check GNU Stow is installed
hash stow 2>/dev/null || {
  echo -e >&2 "\n\e[1;91m❌ ERROR: \e[0mGNU Stow is required but not installed. Aborting."
  exit 1
}

# reset in case getopts has been used previously in the shell
OPTIND=1

# parse options
while getopts "h?vi" opt; do
  case "$opt" in
  h|\?)
    echo "TODO: Create help text..."
    exit 0
    ;;
  v)
    verbosity=vv
    ;;
  i)
    dryrun=false
    ;;
  esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

# do the actual linking for each package
for package in "${PACKAGES[@]}"; do
  echo -e "\n\e[33mInstall package \e[1;96m$package\e[0m\n"
  if [[ $dryrun = true ]]; then
    # dry run
    stow -$verbosity --no --dir="$PACKAGES_DIR" --target="$TARGET_DIR" --restow "$package"
  else
    # install
    stow -$verbosity --dir="$PACKAGES_DIR" --target="$TARGET_DIR" --restow "$package"
  fi
done
