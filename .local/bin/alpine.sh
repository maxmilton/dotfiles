#!/bin/sh -eu
if test "$*" = "-x"; then
  export SYSTEMD_SECCOMP=0
  sudo systemd-nspawn \
    --capability=all \
    --directory=/var/lib/machines/alpine \
    --boot
else
  sudo systemd-nspawn \
    --no-new-privileges=yes \
    --directory=/var/lib/machines/alpine \
    --boot --ephemeral
fi
