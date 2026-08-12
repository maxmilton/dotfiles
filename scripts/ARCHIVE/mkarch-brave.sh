#!/bin/bash
set -eu
set -o pipefail

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

export MACHINE_NAME=brave
export MACHINE_DIR="/home/max/.machines/$MACHINE_NAME"

umask 022

mkdir -p "$MACHINE_DIR"
chown -R root:max "$MACHINE_DIR"
pacstrap -icMG "$MACHINE_DIR" systemd busybox

systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m max && passwd -d max"

mkdir -p "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d
tee -a "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

mkdir -p "$MACHINE_DIR"/home/max/.config/systemd/user
tee -a "$MACHINE_DIR"/home/max/.config/systemd/user/$MACHINE_NAME.service <<EOF
[Unit]
Description=Brave Browser
After=network.target

[Service]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
Environment=QT_QPA_PLATFORM=wayland
Environment=MOZ_ENABLE_WAYLAND=1
Environment=GTK_THEME=Adwaita:dark
ExecStart=/usr/bin/brave --enable-features=UseOzonePlatform --ozone-platform=wayland

[Install]
WantedBy=default.target
EOF

systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R max:max /home/max/.config"
systemd-nspawn -D "$MACHINE_DIR" --user max sh -c "systemctl --user enable $MACHINE_NAME.service"

echo -e "\033[1;31mManually run:\033[0m"
echo "paru -Syr \"$MACHINE_DIR\" brave-bin libpulse ttf-liberation"
