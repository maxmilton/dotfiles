#!/bin/sh -eu
export SYSTEMD_SECCOMP=0
sudo systemd-nspawn \
  --capability=all \
  --directory=/var/lib/machines/alpine \
  --boot
