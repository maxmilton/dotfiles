#!/bin/sh -eu

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

export MACHINE_NAME=librewolf
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
Description=LibreWolf Browser
After=network.target

[Service]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
Environment=QT_QPA_PLATFORM=wayland
Environment=MOZ_ENABLE_WAYLAND=1
Environment=GTK_THEME=Adwaita:dark
ExecStart=/usr/bin/librewolf

[Install]
WantedBy=default.target
EOF

systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R max:max /home/max/.config"
systemd-nspawn -D "$MACHINE_DIR" --user max sh -c "systemctl --user enable $MACHINE_NAME.service"

# NOTE: It may be necessary to import the GPG key for LibreWolf Maintainers:
# gpg --keyserver hkp://keyserver.ubuntu.com --search-keys 8A74EAAF89C17944

echo -e "\033[1;31mManually run:\033[0m"
echo "paru -Syr \"$MACHINE_DIR\" librewolf-bin pipewire-jack wireplumber ttf-liberation"
# Installing librewolf-bin will fail, due to missing dependencies (mime-types
# dbus-glib) which for some reason  are checked on the main system rather than
# the container. Since we installed all the dependencies in the previous step,
# we can now install librewolf-bin omitting the dependencies check.
echo -e "\033[1;31mAnd then:\033[0m"
echo "paru -Syr \"$MACHINE_DIR\" librewolf-bin --nodeps"
