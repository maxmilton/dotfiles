#!/bin/sh -eu

# https://wiki.archlinux.org/title/systemd-nspawn
# https://github.com/AlexMekkering/Arch-Linux/blob/master/docs/systemd-nspawn-containers.md

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1
test -z "$1" && echo "Usage: $0 {name}" >&2 && exit 0

MACHINE_NAME="$1"
MACHINE_DIR="/var/lib/machines/$MACHINE_NAME"

umask 022

mkdir -p "$MACHINE_DIR"
pacstrap -i "$MACHINE_DIR" pacman systemd busybox opendoas

systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m -G wheel max && passwd -d max"

echo "permit persist :wheel" > "$MACHINE_DIR"/etc/doas.conf
# echo "permit root" >> "$MACHINE_DIR"/etc/doas.conf
chmod -c 0400 "$MACHINE_DIR"/etc/doas.conf

mkdir -p "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d
tee -a "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

mkdir -p "/etc/systemd/nspawn"
tee -a "/etc/systemd/nspawn/$MACHINE_NAME.nspawn" <<EOF
[Exec]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
Environment=MOZ_ENABLE_WAYLAND=1
Environment=QT_QPA_PLATFORM=wayland
Environment=GTK_THEME=Adwaita:dark

[Files]
BindReadOnly=/run/user/1000/pulse/native:/run/user/host/pulse/native
BindReadOnly=/run/user/1000/wayland-0:/run/user/host/wayland-0
BindReadOnly=/tmp/.X11-unix/X0
Bind=/dev/dri/card1
Bind=/dev/dri/renderD128
Bind=/home/max/Downloads
BindReadOnly=/home/max/Projects

[Network]
VirtualEthernet=no
EOF

# paru -Sr "$MACHINE_DIR" paru-bin

echo "DONE"
