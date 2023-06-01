#!/bin/sh -eu

# https://wiki.archlinux.org/title/systemd-nspawn
# https://github.com/AlexMekkering/Arch-Linux/blob/master/docs/systemd-nspawn-containers.md

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1
test -z "$1" && echo "Usage: $0 {name}" >&2 && exit 0

export CONTAINER="$1"
export FOLDER="/var/lib/machines/$CONTAINER"

umask 022

mkdir -p "$FOLDER"
pacstrap -iMG "$FOLDER" pacman archlinux-keyring systemd busybox opendoas

systemd-nspawn -D "$FOLDER" sh -c "useradd -m -G wheel max && passwd -d max"

mkdir -p "/etc/systemd/nspawn"
tee -a "/etc/systemd/nspawn/$CONTAINER.nspawn" <<EOF
# [Exec]
# Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
# Environment=DISPLAY=:0
# Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
# Environment=XDG_SESSION_TYPE=wayland
# Environment=MOZ_ENABLE_WAYLAND=1
# Environment=QT_QPA_PLATFORM=wayland
# Environment=GTK_THEME=Adwaita:dark

[Files]
BindReadOnly=/run/user/1000/wayland-0:/run/user/host/wayland-0
BindReadOnly=/tmp/.X11-unix/X0
Bind=/dev/dri/card0
Bind=/dev/dri/renderD128
Bind=/home/max/Downloads
Bind=/home/max/Projects

[Network]
VirtualEthernet=no
EOF

echo "permit persist :wheel" > "$FOLDER"/etc/doas.conf
chmod -c 0400 "$FOLDER"/etc/doas.conf
ln -s "$FOLDER"/usr/bin/doas "$FOLDER"/usr/bin/sudo

mkdir -p "$FOLDER"/etc/systemd/system/console-getty.service.d
tee -a "$FOLDER"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

# sudo machinectl shell $CONTAINER /usr/bin/pacman-key --populate archlinux
