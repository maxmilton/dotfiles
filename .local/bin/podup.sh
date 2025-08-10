#!/bin/bash
set -Eeuo pipefail

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

for cmd in podman rg xargs; do
   command -v "$cmd" >/dev/null 2>&1 || die "Error: ${cmd} not found"
done

msg 'Updating remote images...'
podman images --filter dangling=false --format "{{.Repository}}:{{.Tag}}" | \
   rg -v '<none>|localhost/' | \
   xargs -r podman pull || {
       msg 'Warning: Some pulls failed'
   }

msg 'Removing dangling images...'
podman image prune -f

msg 'Done'
