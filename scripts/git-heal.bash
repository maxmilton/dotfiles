#!/usr/bin/env bash
# https://claude.ai/chat/dac0ba75-d46a-4c52-a548-4f604025ce82
# git-heal [-n] [root…]  — find every repo/submodule/worktree under root, check + repair
#   -n  dry run (report only)
set -uo pipefail
export DRY=0
[[ ${1:-} == -n ]] && { DRY=1; shift; }

heal() {
  local wt=${1%/.git} gd broken=0 s f
  run() { if ((DRY)); then echo "    would: $*"; else "$@"; fi; }
  g()   { git -C "$wt" "$@"; }

  gd=$(g rev-parse --absolute-git-dir 2>/dev/null) || { echo "✗ $wt: unreadable .git"; return 1; }
  echo "• $wt"

  # stale locks: >5 min old ⇒ owner is dead
  while IFS= read -r -d '' f; do
    echo "    stale lock ${f#"$gd"/}"; run rm -f "$f"
  done < <(find "$gd" -path "$gd/objects" -prune -o -name '*.lock' -mmin +5 -print0)

  # zero-byte loose objects/packs (power-loss corruption) — fsck/refetch below restores them
  while IFS= read -r -d '' f; do
    echo "    empty object ${f#"$gd"/}"; run rm -f "$f"
  done < <(find "$gd/objects" -type f -empty -print0)

  # corrupt index → rebuild from HEAD, worktree untouched
  g ls-files >/dev/null 2>&1 || { echo "    corrupt index"; run rm -f "$gd/index"; run g reset -q; }

  # objects, refs, commit-graph, midx
  g fsck --full --no-dangling --no-progress >/dev/null 2>&1 || broken=1
  if ((broken)) && [[ -n $(g remote) ]]; then
    echo "    refetching"; run g fetch --all --refetch --quiet
    g fsck --full --no-dangling --no-progress >/dev/null 2>&1 && broken=0
  fi
  ((broken)) && { echo "    ✗ still corrupt: git -C '$wt' fsck --full"; return 1; }

  # in-progress ops: report, never auto-abort
  for s in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG; do
    [[ -e $gd/$s ]] && echo "    ⚠ in progress: $s"
  done

  run g worktree prune
  if [[ -f $wt/.gitmodules ]]; then
    run g submodule sync -q --recursive
    # init only missing ones; don't move checked-out submodules off their branches
    g submodule status --recursive | awk '$1 ~ /^-/ {print $2}' |
      while read -r s; do run g submodule update -q --init -- "$s"; done
  fi
  run g gc --quiet   # default 2-week prune grace, not --prune=now: keeps jj op-log/reflog-only commits
  [[ -d $wt/.jj ]] && command -v jj >/dev/null && run jj -R "$wt" --quiet git import
}
export -f heal

# "$1" is intentionally expanded by the child Bash process.
# shellcheck disable=SC2016
fd -HI --prune -t d -t f -E node_modules '^\.git$' "${@:-.}" -x bash -c 'heal "$1"' _ {}
