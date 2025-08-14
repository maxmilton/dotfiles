#!/bin/bash
set -eu
set -o pipefail

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1
test -z "$1" && echo "Usage: $0 {name}" >&2 && exit 0

MACHINE_NAME="$1"
MACHINE_DIR="/var/lib/machines/$MACHINE_NAME"
MIRROR="http://dl-cdn.alpinelinux.org/alpine"
VERSION="edge"  # or "latest-stable"

apkdir="$(mktemp -d)"
test "$(uname -m)" = "x86_64" && guestarch="x86_64" || guestarch="x86"

APKTOOLS="$(wget -q -O - "$MIRROR/$VERSION/main/$guestarch/" | grep -Eo -m 1 '>apk-tools-static[^<]+' | sed 's/[<>]//g')"

wget -q -O - "$MIRROR/$VERSION/main/$guestarch/$APKTOOLS" | tar -xz -C "$apkdir" || { rm -rf "$apkdir"; exit 1; }
trap 'rm -rf "$apkdir"' EXIT

"$apkdir/sbin/apk.static" -X "$MIRROR/$VERSION/main" -U --arch "$guestarch" --allow-untrusted --root "$MACHINE_DIR" --initdb add alpine-base

echo "$MIRROR/$VERSION/main" > "$MACHINE_DIR/etc/apk/repositories"
echo "$MIRROR/$VERSION/community" >> "$MACHINE_DIR/etc/apk/repositories"

systemd-nspawn -D "$MACHINE_DIR" sh -c "adduser -Dg max max && adduser max wheel && passwd -d max"
systemd-nspawn -D "$MACHINE_DIR" sh -c "apk add --no-cache doas && echo 'permit persist :wheel' > /etc/doas.conf && chmod -c 0400 /etc/doas.conf"

for i in $(seq 0 10); do
  echo "pts/$i" >> "$MACHINE_DIR/etc/securetty"
done

sed -i '/tty[0-9]:/ s/^/#/' "$MACHINE_DIR/etc/inittab"
echo 'console::respawn:/sbin/getty 38400 console' >> "$MACHINE_DIR/etc/inittab"

for svc in bootmisc hostname syslog; do
  ln -s "/etc/init.d/$svc" "$MACHINE_DIR/etc/runlevels/boot/$svc"
done

for svc in killprocs savecache; do
  ln -s "/etc/init.d/$svc" "$MACHINE_DIR/etc/runlevels/shutdown/$svc"
done

mkdir -p "/etc/systemd/nspawn"
tee -a "/etc/systemd/nspawn/$MACHINE_NAME.nspawn" <<EOF
[Files]
BindReadOnly=/home/max/Projects

[Network]
VirtualEthernet=no
EOF

echo "DONE"
