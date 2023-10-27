#!/bin/sh -eu

if test -L /usr/bin/sudo; then
  doas sudo rm /usr/bin/sudo
fi

doas pacman -S --noconfirm --needed base-devel nodejs

script_dir="$(cd "$(dirname "$0")" && pwd)"
doas "$script_dir"/link-busybox.sh
doas ln -vs --no-dereference /usr/bin/busybox /usr/local/bin/unzip

curl -fsSL https://bun.sh/install | bash

~/.bun/bin/bun add -g pnpm npm yarn
~/.bun/bin/yarn set version stable
