#!/bin/sh -eu

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

export CONTAINER=brave
export FOLDER="/home/max/machines/$CONTAINER"

umask 022

mkdir -p "$FOLDER"
chown -R root:max "$FOLDER"
pacstrap -icMG "$FOLDER" systemd busybox

systemd-nspawn -D "$FOLDER" sh -c "useradd -m max && passwd -d max"

mkdir -p "$FOLDER"/etc/systemd/system/console-getty.service.d
tee -a "$FOLDER"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

mkdir -p "$FOLDER"/home/max/.config/systemd/user
tee -a "$FOLDER"/home/max/.config/systemd/user/$CONTAINER.service <<EOF
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

systemd-nspawn -D "$FOLDER" sh -c "chown -R max:max /home/max/.config"
systemd-nspawn -D "$FOLDER" --user max sh -c "systemctl --user enable $CONTAINER.service"

echo -e "\033[1;31mManually run:\033[0m"
echo "paru -Syr \"$FOLDER\" brave-bin libpulse ttf-liberation"
