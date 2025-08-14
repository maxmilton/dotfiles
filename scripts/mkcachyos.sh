#!/bin/bash
set -eu
set -o pipefail

# https://wiki.archlinux.org/title/systemd-nspawn
# https://github.com/AlexMekkering/Arch-Linux/blob/master/docs/systemd-nspawn-containers.md

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1
test -z "$1" && echo "Usage: $0 {name}" >&2 && exit 0

MACHINE_NAME="$1"
MACHINE_DIR="/var/lib/machines/$MACHINE_NAME"

umask 022

mkdir -p "$MACHINE_DIR"
pacstrap -icP "$MACHINE_DIR" systemd busybox opendoas pacman paru
# paru --root "$MACHINE_DIR" --cachedir /var/cache/pacman/pkg -S paru

chmod -c 0644 "$MACHINE_DIR"/etc/pacman.conf
cp /etc/pacman.d/*-mirrorlist "$MACHINE_DIR"/etc/pacman.d/
echo -e "[bin]\nSudo = doas" >> "$MACHINE_DIR"/etc/paru.conf

systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m -G wheel max && passwd -d max"
ln -s /home/max/Projects/dotfiles/.profile "$MACHINE_DIR"/home/max/.profile
echo '[[ $- != *i* ]] || . ~/.profile' > "$MACHINE_DIR"/home/max/.bashrc

echo "permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel" > "$MACHINE_DIR"/etc/doas.conf
chmod -c 0400 "$MACHINE_DIR"/etc/doas.conf

mkdir -p "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d
tee -a "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

ln -s busybox "$MACHINE_DIR"/usr/bin/bc
ln -s busybox "$MACHINE_DIR"/usr/bin/iostat
ln -s busybox "$MACHINE_DIR"/usr/bin/lsof
ln -s busybox "$MACHINE_DIR"/usr/bin/nc
ln -s busybox "$MACHINE_DIR"/usr/bin/netstat
ln -s busybox "$MACHINE_DIR"/usr/bin/ping
ln -s busybox "$MACHINE_DIR"/usr/bin/tar
ln -s busybox "$MACHINE_DIR"/usr/bin/telnet
ln -s busybox "$MACHINE_DIR"/usr/bin/traceroute
ln -s busybox "$MACHINE_DIR"/usr/bin/unzip
ln -s busybox "$MACHINE_DIR"/usr/bin/vi
ln -s busybox "$MACHINE_DIR"/usr/bin/wget
ln -s busybox "$MACHINE_DIR"/usr/bin/whois

# NOTE: The `machinectl shell` command does not support --ephemeral so no point
# in making an nspawn config.

echo "DONE"
