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

set -o errtrace # trap errors inside functions
trap 'echo -e "\x1B[1;91mError during install!\x1B[0m"' ERR EXIT

# options
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$HOME
IGNORE_FILES="^((pre|post)-install|.*-entrypoint)\\.sh$"
CONFIG_FILENAME=.dotfilesrc

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

usage() {
  echo -e "
Usage: ${YELLOW}$(basename "$0") [OPTIONS] [PACKAGES]${RESET}

Dotfiles package installer script.

OPTIONS:
  -h  Show this help text and exit.
  -i  Install packages (without this a dry run is performed).
  -q  Don't print info text to console.
  -v  Enable verbose output.

PACKAGES:
  The name/s of config packages to install. The package name is
  the same as the directory name. This is optional and if not
  specified the packages will be installed from ${CYAN}.dotfilesrc${RESET}.

  You can place a ${CYAN}.dotfilesrc${RESET} in your home directory to
  customise which packages are installed, otherwise the script
  will fallback to the ${CYAN}.dotfilesrc${RESET} supplied in the repo.
  ${CYAN}.dotfilesrc${RESET} should be a line seperated list of packages.
  " >&1
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# initialise variables

packages=
ARGV=("$@")
OS=$(uname)
DISTRO='Not Linux'

if [[ "$OS" = 'Linux' ]]; then
  DISTRO=$(awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')
fi

# variables for use in install scripts

# colours
export readonly RESET='\x1B[0m'
export readonly BLUE='\x1B[0;94m'
export readonly CYAN_BOLD='\x1B[1;96m'
export readonly CYAN='\x1B[0;96m'
export readonly GREEN='\x1B[0;92m'
export readonly RED_BOLD='\x1B[1;91m'
export readonly YELLOW_BOLD='\x1B[1;93m'
export readonly YELLOW='\x1B[0;33m'

# runtime settings
export readonly ARGV
export readonly SOURCE_DIR
export readonly TARGET_DIR
export readonly IGNORE_FILES
export readonly CONFIG_FILENAME
export readonly OS
export readonly DISTRO
export readonly CMD=echo_dryrun
export readonly DRYRUN=true
export readonly QUIET=false
export readonly V=-v

# feedback utilities
echo_err() { echo -e "\\n${RED_BOLD}❌ ERROR:${RESET} ${*}${RESET}" 1>&2; }
echo_warn() { echo -e "\\n${YELLOW_BOLD}🔶 WARNING:${RESET} ${*}${RESET}" 1>&2; }
echo_info() { [[ $QUIET == true ]] || echo -e "${*}${RESET}" >&1; }
echo_dryrun() { local IFS=' '; echo -e "${GREEN}DRY RUN:${RESET} ${*}"; }

export -f echo_err
export -f echo_warn
export -f echo_info
export -f echo_dryrun

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

  # check curl is installed
  if ! hash curl 2>/dev/null; then
    echo_warn 'Curl is required by some packages but not installed.'
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

    echo_info "Using packages configured in ${dotfilesrc}"

    readarray -t packages < "$dotfilesrc"
  fi

  if [[ $DRYRUN = true ]]; then
    local IFS=' '
    echo_warn "Doing dry run. Check output then run ${YELLOW}$(basename "$0") -i ${ARGV[*]}"
  fi

  # do the actual linking for each package and run pre/post script hooks
  for package in "${packages[@]}"; do
    echo_info "\\n${BLUE}Installing ${CYAN_BOLD}$package ${BLUE}package..."

    if [[ -f "$SOURCE_DIR/$package/pre-install.sh" ]]; then
      # shellcheck source=/dev/null
      source "$SOURCE_DIR/$package/pre-install.sh"
    fi

    if [[ $DRYRUN = true ]]; then
      stow \
        $V \
        --no \
        --dir="$SOURCE_DIR" \
        --target="$TARGET_DIR" \
        --ignore="$IGNORE_FILES" \
        --restow \
        "$package"
    else
      stow \
        $V \
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

# Reset var in case getopts had been previously used in the shell
OPTIND=1

# parse options
while getopts "h?iqv" opt; do
  case "$opt" in
    h|\?)
      usage
      exit 0
      ;;
    i)
      export readonly DRYRUN=false
      export readonly CMD=
      ;;
    q)
      export readonly QUIET=true
      export readonly V=
      ;;
    v)
      export readonly V=-vv
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
