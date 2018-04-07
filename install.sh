#!/bin/bash

#
# INSTALL DOTFILES
#
# Creates symlinks to dotfiles in the user home directory. Running this script
# multiple times is completely fine to install additional packages.
#

set -e

STOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
# disable package by commenting its line
PACKAGES=(
  bash
  fish
  git
  #hg
  #terraform
  #tmux
  tslint
  vim
  vscode
  yarn
  zsh
)

# TODO: Check GNU stow is installed.

# TODO: Check repo is up to date

# TODO: Run stow against each package

