#!/bin/bash
set -eu
set -o pipefail

# TODO: Populate persistent data rather than populate on every run
doas pacman -S --noconfirm --needed archlinux-keyring
doas pacman-key --init
doas pacman-key --populate archlinux

if test -L /usr/bin/sudo; then
  doas rm /usr/bin/sudo
fi

doas pacman -S --noconfirm --needed base-devel nodejs

script_dir="$(cd "$(dirname "$0")" && pwd)"
doas "$script_dir"/link-busybox.sh
doas ln -vs --no-dereference /usr/bin/busybox /usr/local/bin/unzip

curl -fsSL https://bun.sh/install -o bun-install.sh
"7713fe768665f07a90fd7ac5eb25c9e8838703a560ba7ad942bdcedd92dc115b bun-install.sh" | sha256sum -c -
sh bun-install.sh

~/.bun/bin/bun add -g pnpm npm yarn
~/.bun/bin/yarn set version stable

echo "export PATH=$PATH:~/.bun/bin/"
