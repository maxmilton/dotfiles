#!/bin/sh -eu

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

export CONTAINER=vms
export FOLDER="/home/max/.machines/$CONTAINER"

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
Description=Gnome Boxes
After=network.target

[Service]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
Environment=QT_QPA_PLATFORM=wayland
Environment=MOZ_ENABLE_WAYLAND=1
Environment=GTK_THEME=Adwaita:dark
ExecStart=/usr/bin/gnome-boxes

[Install]
WantedBy=default.target
EOF

systemd-nspawn -D "$FOLDER" sh -c "chown -R max:max /home/max/.config"
systemd-nspawn -D "$FOLDER" --user max sh -c "systemctl --user enable $CONTAINER.service"

echo -e "\033[1;31mManually run:\033[0m"
echo "paru -Syr \"$FOLDER\" gnome-boxes libpulse pipewire-jack wireplumber"

# https://www.geekdashboard.com/install-windows-11-on-gnome-boxes/
echo -e "\033[1;31mFor Windows 11, also run:\033[0m"
echo "paru -Syr \"$FOLDER\" edk2-ovmf swtpm"
echo -e "\033[1;31mThen, in the container, run:\033[0m"
echo "swtpm_setup --create-config-files skip-if-exist"

# Edit VM preferences:

# Add to end of <devices>:
# <tpm model="tpm-crb">
#   <backend type="emulator" version="2.0"/>
# </tpm>

# Add to end of <os>:
# <loader readonly="yes" type="pflash">/usr/share/edk2/x64/OVMF_CODE.secboot.fd</loader>


# TODO: The rest seems to be unnecessary as long as you save the VM config

# awk grep
# # FOLDER="/home/max/.machines/vms"
# # systemd-nspawn -D "$FOLDER" sh -c "ln -s /usr/bin/busybox /usr/local/bin/vi"
# systemd-nspawn -D "$FOLDER" sh -c "ln -s /usr/bin/busybox /usr/local/bin/awk"
# systemd-nspawn -D "$FOLDER" sh -c "ln -s /usr/bin/busybox /usr/local/bin/grep"
# systemd-nspawn -D "$FOLDER" sh -c "ln -s /usr/bin/busybox /usr/local/bin/sed"


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
