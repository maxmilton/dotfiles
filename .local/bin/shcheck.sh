#!/bin/bash
set -euo pipefail

# Check all tracked shell scripts in a Git or jj repository.
# Usage: shcheck.sh [directory] (defaults to the current repository)
# Requires: git or jj, grep, shellcheck; symlinks and *.bak paths are excluded.
if (($# > 1)); then
  printf 'Usage: %s [directory]\n' "${0##*/}" >&2
  exit 2
fi

cd -- "${1:-.}"
if command -v jj >/dev/null 2>&1 && repo_root=$(jj --ignore-working-copy root 2>/dev/null); then
  list_files=(jj --no-pager --color=never file list -T 'path ++ "\0"')
else
  repo_root=$(git rev-parse --show-toplevel)
  list_files=(git ls-files -z)
fi
cd -- "$repo_root"

scripts=()
bash_startup=()
sh_startup=()
shebang='^#![[:blank:]]*([^[:blank:]]*/)?(env[[:blank:]]+(-S[[:blank:]]+)?)?((sh|bash|bats|dash|ksh|ash)|busybox[[:blank:]]+(sh|ash))([[:blank:]]|$)'
directive='^[[:blank:]]*#[[:blank:]]*shellcheck[[:blank:]]+shell=(sh|bash|dash|ksh|busybox)([[:blank:],]|$)'

while IFS= read -r -d '' file; do
  case "$file" in
    *.bak|*.bak/*) continue ;;
  esac
  [[ -f "$file" && ! -L "$file" ]] || continue

  case "${file##*/}" in
    .bashrc|.bash_profile) bash_startup+=("$file"); continue ;;
    .profile) sh_startup+=("$file"); continue ;;
  esac

  case "$file" in
    *.sh|*.bash|*.bats|*.dash|*.ksh) ;;
    *)
      first_line=''
      IFS= read -r first_line < "$file" || [[ -n "$first_line" ]] || continue
      [[ "$first_line" =~ $shebang ]] || grep -Eq "$directive" -- "$file" || continue
      ;;
  esac
  scripts+=("$file")
done < <("${list_files[@]}")
# Process substitution runs asynchronously; propagate file-list failures.
wait "$!"

status=0
if ((${#scripts[@]})); then
  shellcheck --norc -ax -- "${scripts[@]}" || status=1
fi
if ((${#bash_startup[@]})); then
  shellcheck --norc -ax --shell=bash -- "${bash_startup[@]}" || status=1
fi
if ((${#sh_startup[@]})); then
  shellcheck --norc -ax --shell=sh -- "${sh_startup[@]}" || status=1
fi
exit "$status"
