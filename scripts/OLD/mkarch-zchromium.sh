#!/bin/sh
set -eu
set -o pipefail

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

test "$(id -u)" -eq "0" && die "Do not run as root"

export MACHINE_NAME="${MACHINE_NAME:-zchromium}"
export MACHINE_DIR="${HOME}/.machines/${MACHINE_NAME}"

umask 022

sudo mkdir -pv "${MACHINE_DIR}/var/lib/pacman"
sudo chown root:"$(id -gn)" "$MACHINE_DIR"

sudo ln -svf /var/lib/pacman/sync "${MACHINE_DIR}/var/lib/pacman/"

sudo pacstrap -icMG "$MACHINE_DIR" systemd
sudo paru --root "$MACHINE_DIR" --cachedir /var/cache/pacman/pkg -S chromium \
  at-spi2-core libcups libpulse libxcomposite libxdamage libxkbcommon libxrandr mesa pango \
  --assume-installed adwaita-fonts \
  --assume-installed gtk3 \
  --assume-installed ttf-font

sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m xxxx && passwd -d xxxx"

sudo mkdir -pv "${MACHINE_DIR}/etc/systemd/system/console-getty.service.d"
sudo tee -a "${MACHINE_DIR}/etc/systemd/system/console-getty.service.d/autologin.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin xxxx - 115200,38400,9600 \$TERM
EOF

sudo mkdir -pv "${MACHINE_DIR}/home/xxxx/.config/systemd/user"
sudo tee -a "${MACHINE_DIR}/home/xxxx/.config/systemd/user/${MACHINE_NAME}.service" <<EOF
[Unit]
Description=Chromium Browser
After=network.target

[Service]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
ExecStart=/usr/bin/chromium --ozone-platform-hint=wayland --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3

[Install]
WantedBy=default.target
EOF

sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R xxxx:xxxx /home/xxxx/.config"
sudo systemd-nspawn -D "$MACHINE_DIR" --user xxxx sh -c "systemctl --user enable ${MACHINE_NAME}.service"

msg "DONE"
