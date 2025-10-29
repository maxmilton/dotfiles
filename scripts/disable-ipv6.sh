#!/bin/sh
set -eu

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
