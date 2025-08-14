#!/bin/bash
set -eu
set -o pipefail

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

test "$(id -u)" -eq "0" && die "Do not run as root"

export MACHINE_NAME="${MACHINE_NAME:-vms}"
export MACHINE_DIR="${HOME}/.machines/${MACHINE_NAME}"

umask 022

# //////////////////////////////////////////////////////

# mkdir -p "$MACHINE_DIR"
# chown -R root:max "$MACHINE_DIR"
# pacstrap -icMG "$MACHINE_DIR" systemd busybox

# systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m max && passwd -d max"

# mkdir -p "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d
# tee -a "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
# [Service]
# ExecStart=
# ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
# EOF

# mkdir -p "$MACHINE_DIR"/home/max/.config/systemd/user
# tee -a "$MACHINE_DIR"/home/max/.config/systemd/user/$CONTAINER.service <<EOF
# [Unit]
# Description=Gnome Boxes
# After=network.target

# [Service]
# Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
# Environment=DISPLAY=:0
# Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
# Environment=XDG_SESSION_TYPE=wayland
# Environment=QT_QPA_PLATFORM=wayland
# Environment=MOZ_ENABLE_WAYLAND=1
# Environment=GTK_THEME=Adwaita:dark
# ExecStart=/usr/bin/gnome-boxes

# [Install]
# WantedBy=default.target
# EOF

# systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R max:max /home/max/.config"
# systemd-nspawn -D "$MACHINE_DIR" --user max sh -c "systemctl --user enable $CONTAINER.service"

# echo -e "\033[1;31mManually run:\033[0m"
# echo "paru -Syr \"$MACHINE_DIR\" gnome-boxes libpulse pipewire-jack wireplumber"

# # https://www.geekdashboard.com/install-windows-11-on-gnome-boxes/
# echo -e "\033[1;31mFor Windows 11, also run:\033[0m"
# echo "paru -Syr \"$MACHINE_DIR\" edk2-ovmf swtpm"
# echo -e "\033[1;31mThen, in the container, run:\033[0m"
# echo "swtpm_setup --create-config-files skip-if-exist"

# //////////////////////////////////////////////////////

# https://www.geekdashboard.com/install-windows-11-on-gnome-boxes/

sudo mkdir -pv "${MACHINE_DIR}/var/lib/pacman"
sudo chown root:"$(id -gn)" "$MACHINE_DIR"

sudo ln -svf /var/lib/pacman/sync "${MACHINE_DIR}/var/lib/pacman/"

sudo pacstrap -icMG "$MACHINE_DIR" systemd
sudo paru --root "$MACHINE_DIR" --cachedir /var/cache/pacman/pkg -S gnome-boxes edk2-ovmf swtpm

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
Description=Gnome Boxes
After=network.target

[Service]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
ExecStart=/usr/bin/gnome-boxes

[Install]
WantedBy=default.target
EOF

sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R xxxx:xxxx /home/xxxx/.config"
sudo systemd-nspawn -D "$MACHINE_DIR" --user xxxx sh -c "wtpm_setup --create-config-files skip-if-exist"
sudo systemd-nspawn -D "$MACHINE_DIR" --user xxxx sh -c "systemctl --user enable ${MACHINE_NAME}.service"

msg "DONE"

# //////////////////////////////////////////////////////

# Edit VM preferences:

# Add to end of <devices>:
# <tpm model="tpm-crb">
#   <backend type="emulator" version="2.0"/>
# </tpm>

# Add to end of <os>:
# <loader readonly="yes" type="pflash">/usr/share/edk2/x64/OVMF_CODE.secboot.fd</loader>


# TODO: The rest seems to be unnecessary as long as you save the VM config

# awk grep
# # MACHINE_DIR="${HOME}/.machines/vms"
# # systemd-nspawn -D "$MACHINE_DIR" sh -c "ln -s /usr/bin/busybox /usr/local/bin/vi"
# systemd-nspawn -D "$MACHINE_DIR" sh -c "ln -s /usr/bin/busybox /usr/local/bin/awk"
# systemd-nspawn -D "$MACHINE_DIR" sh -c "ln -s /usr/bin/busybox /usr/local/bin/grep"
# systemd-nspawn -D "$MACHINE_DIR" sh -c "ln -s /usr/bin/busybox /usr/local/bin/sed"


# Create desktop file:
# mkdir -p ~/.local/share/applications/
# busybox vi ~/.local/share/applications/vi.desktop

# [Desktop Entry]
# Name=BusyBox Vi
# Comment=Text Editor (Vi)
# Exec=busybox vi %F
# Terminal=true
# Type=Application
# Icon=utilities-text-editor
# MimeType=text/plain;

# Associate:
# xdg-mime default vi.desktop x-scheme-handler/text
# xdg-settings set default-url-scheme-handler text vi.desktop

# Verify:
# xdg-mime query default x-scheme-handler/text
# xdg-mime query default text/plain
