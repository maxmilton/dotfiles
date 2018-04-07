#!/bin/bash

#
# INSTALL DOTFILES
#
# Creates symlinks to dotfiles in the user home directory. Running this script
# multiple times is completely fine to update or install additional packages.
#

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

# check GNU Stow is installed
hash stow 2>/dev/null || { echo -e >&2 "\n\e[1;91m❌ ERROR: \e[0mGNU Stow is required but not installed. Aborting."; exit 1; }

for package in "${PACKAGES[@]}"; do
  echo -e "\n\e[33mInstall package \e[1;96m$package\e[0m\n"
  #echo -e "stow -v --no --dir=$PACKAGES_DIR --target=$TARGET_DIR --restow $package"
  if [[ $dryrun = true ]]; then
    # dry run
    stow -v --no --dir=$PACKAGES_DIR --target=$TARGET_DIR --restow $package
  else
    stow -v --dir=$PACKAGES_DIR --target=$TARGET_DIR --restow $package
  fi
done

