#!/bin/sh
set -eu
set -o pipefail

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

export MACHINE_NAME=zbrave
export MACHINE_DIR="$HOME/.machines/$MACHINE_NAME"

umask 022

GROUP="$(id -gn)"

mkdir -p "$MACHINE_DIR"
chown -R root:"$GROUP" "$MACHINE_DIR"

pacstrap -icMG "$MACHINE_DIR" systemd
paru --root "$MACHINE_DIR" --cachedir /var/cache/pacman/pkg -S brave-bin libpulse ttf-liberation \
  --assume-installed adwaita-cursors adwaita-icon-theme-legacy adobe-source-code-pro-fonts adwaita-icon-theme cantarell-fonts default-cursors desktop-file-utils duktape gsettings-desktop-schemas gsettings-system-schemas hicolor-icon-theme libcloudproviders gtk-update-icon-cache

systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m $USER && passwd -d $USER"

mkdir -p "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d
tee -a "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin $USER - 115200,38400,9600 \$TERM
EOF

mkdir -p "$MACHINE_DIR"/home/"$USER"/.config/systemd/user
tee -a "$MACHINE_DIR"/home/"$USER"/.config/systemd/user/$MACHINE_NAME.service <<EOF
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
ExecStart=/usr/bin/brave --ozone-platform-hint=wayland --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3

[Install]
WantedBy=default.target
EOF

systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R $USER:$GROUP /home/$USER/.config"
systemd-nspawn -D "$MACHINE_DIR" --user "$USER" sh -c "systemctl --user enable $MACHINE_NAME.service"

echo "DONE"
