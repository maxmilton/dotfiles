#!/bin/sh -eu

MIRROR="http://dl-cdn.alpinelinux.org/alpine"
#VERSION="latest-stable"
VERSION="edge"

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1
test -z "$1" && echo "Usage: $0 destination" >&2 && exit 0

dest="$1"
apkdir="$(mktemp -d)"
test "$(uname -m)" = "x86_64" && guestarch="x86_64" || guestarch="x86"

APKTOOLS="$(wget -q -O - "$MIRROR/$VERSION/main/$guestarch/" | grep -Eo -m 1 '>apk-tools-static[^<]+' | sed 's/[<>]//g')"

wget -q -O - "$MIRROR/$VERSION/main/$guestarch/$APKTOOLS" | tar -xz -C $apkdir || { rm -rf "$apkdir"; exit 1; }
trap 'rm -rf "$apkdir"' EXIT

"$apkdir/sbin/apk.static" -X "$MIRROR/$VERSION/main" -U --arch "$guestarch" --allow-untrusted --root "$dest" --initdb add alpine-base

echo "$MIRROR/$VERSION/main" > "$dest/etc/apk/repositories"
echo "$MIRROR/$VERSION/community" >> "$dest/etc/apk/repositories"

for i in $(seq 0 10); do
    echo "pts/$i" >> "$dest/etc/securetty"
done

sed -i '/tty[0-9]:/ s/^/#/' "$dest/etc/inittab"
echo 'console::respawn:/sbin/getty 38400 console' >> "$dest/etc/inittab"

for svc in bootmisc hostname syslog; do
    ln -s "/etc/init.d/$svc" "$dest/etc/runlevels/boot/$svc"
done

for svc in killprocs savecache; do
    ln -s "/etc/init.d/$svc" "$dest/etc/runlevels/shutdown/$svc"
done

echo "Success"
