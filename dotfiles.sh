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
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
IGNORE_FILES="^((pre|post)-install|.*-entrypoint)\\.sh$"
CONFIG_FILENAME=.dotfilesrc

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
  specified the packages will be installed from ${cyan}.dotfilesrc${reset}.

  You can place a ${cyan}.dotfilesrc${reset} in your home directory to
  customise which packages are installed, otherwise the script
  will fallback to the ${cyan}.dotfilesrc${reset} supplied in the repo.
  ${cyan}.dotfilesrc${reset} should be a line seperated list of packages.
  " >&1
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# colours
export readonly reset='\x1B[0m'
export readonly blue='\x1B[0;94m'
export readonly cyan_bold='\x1B[1;96m'
export readonly cyan='\x1B[0;96m'
export readonly green='\x1B[0;92m'
export readonly red_bold='\x1B[1;91m'
export readonly yellow_bold='\x1B[1;93m'
export readonly yellow='\x1B[0;33m'

packages=

# runtime settings
export cmd=echo_dryrun
export dryrun=true
export quiet=false
export v=-v

# variables for use in install scripts
OS=$(uname)
DISTRO='Not Linux'

if [[ "$OS" = 'Linux' ]]; then
  DISTRO=$(awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')
fi

export readonly OS
export readonly DISTRO

# feedback utilities
echo_err() { echo -e "\\n${red_bold}❌ ERROR:${reset} ${*}${reset}" 1>&2; }
echo_warn() { echo -e "\\n${yellow_bold}🔶 WARNING:${reset} ${*}${reset}" 1>&2; }
echo_info() { [[ $quiet == true ]] || echo -e "${*}${reset}" >&1; }
echo_dryrun() { local IFS=' '; echo -e "${green}DRY RUN:${reset} ${*}"; }

check_requirements() {
  # check minimum version of bash
  if [[ $(bash --version | awk '{print $2}') < 4.0.0 ]]; then
    echo_err 'Bash version 4.0.0 or higher is required. Aborting.'
    exit 1
  fi

  # check GNU Stow is installed
  if ! hash stow 2>/dev/null; then
    echo_err 'GNU Stow is required but not installed. Aborting.'
    exit 1
  fi
}

get_dotfilesrc() {
  if [[ -f "$HOME"/"$CONFIG_FILENAME" ]]; then
    echo "$HOME"/"$CONFIG_FILENAME"
  else
   echo "$SOURCE_DIR"/"$CONFIG_FILENAME"
  fi
}

install_packages() {
  if [[ -z "$packages" ]]; then
    local dotfilesrc
    dotfilesrc=$(get_dotfilesrc)

    echo_info "Using packages from ${dotfilesrc}"

    readarray -t packages < "$dotfilesrc"
  fi

  if [[ $dryrun = true ]]; then
    echo_warn "Doing dry run. Check output then run ${yellow}$(basename "$0") -i ${BASH_ARGV[*]}"
  fi

  # do the actual linking for each package and run pre/post script hooks
  for package in "${packages[@]}"; do
    echo_info "\\n${blue}Installing ${cyan_bold}$package ${blue}package..."

    if [[ -f "$SOURCE_DIR/$package/pre-install.sh" ]]; then
      # shellcheck source=/dev/null
      source "$SOURCE_DIR/$package/pre-install.sh"
    fi

    if [[ $dryrun = true ]]; then
      stow \
        $v \
        --no \
        --dir="$SOURCE_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"
    else
      stow \
        $v \
        --dir="$SOURCE_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"
    fi

    if [[ -f "$SOURCE_DIR/$package/post-install.sh" ]]; then
      # shellcheck source=/dev/null
      source "$SOURCE_DIR/$package/post-install.sh"
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
      export cmd=
      ;;
    q)
      export quiet=true
      export v=
      ;;
    v)
      export v=-vv
      ;;
  esac
done

shift $((OPTIND-1))

# handle package names passed in as args
if [[ "$#" != 0 ]]; then
  packages=("$@")
fi

# run functions
check_requirements
install_packages
