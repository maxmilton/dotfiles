#!/bin/sh
set -eu
if test "$*" = "-x"; then
  export SYSTEMD_SECCOMP=0
  sudo systemd-nspawn \
    --directory=/var/lib/machines/alpine \
    --capability=all \
    --boot
else
  sudo systemd-nspawn \
    --directory=/var/lib/machines/alpine \
    --no-new-privileges=yes \
    --boot --ephemeral
fi
