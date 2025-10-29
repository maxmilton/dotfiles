#!/bin/sh
set -eu

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

# systemctl start libvirtd.service
# virsh net-start --network default
virsh net-start default
