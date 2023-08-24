# Notes

## Useful Commands

```sh
# show important messages from this boot
journalctl -b -f -n 1000 --priority 0..5
```

```sh
# clone repo but only fetch required content nodes
git clone --filter=blob:none <url>
```

```sh
rg --no-ignore --hidden
```

```sh
rg --context 3 --max-columns 80 --max-columns-preview
```

```sh
# recursively set directory permissions to 700
fd --type d --hidden --no-ignore --exec chmod -c 700 {}
```

```sh
# DO NOT USE; fd can't filter out executable files
# recursively set ALL file permissions to 600
#fd --type f --hidden --no-ignore --exec chmod -c 600 {}
```

```sh
# recursively set file permissions to 600 (excluding executables)
find -O3 . -type f ! -executable -exec chmod -c 600 {} \;
```

```sh
# recursively set file permissions to 700 (executables only)
fd --type x --hidden --no-ignore --exec chmod -c 700 {}
```

```sh
# remove broken symlinks in dir
find -L . -name . -o -type d -prune -o -type l -exec /bin/rm -rf {} \;
```

```sh
# remove node_modules dirs recursively
fd --type directory --hidden --no-ignore-vcs --exec /bin/rm -rf {} \; node_modules .
```

```sh
# remove yarn-error.log files recursively
fd --type file --hidden --exec /bin/rm -rf {} \; yarn-error.log .
```

```sh
curl https://ifconfig.me/all
```

```sh
# debug bash script
env PS4="\$(if [[ \$? == 0 ]]; then echo \"\033[0;33mEXIT: \$? ✔\"; else echo \"\033[1;91mEXIT: \$? ❌\033[0;33m\"; fi)\n\nSTACK:\n\${BASH_SOURCE[0]}:\${LINENO}\n\${BASH_SOURCE[*]:1}\n\033[0m" bash -x
```

```sh
# remove missing files from git working tree
git ls-files --deleted -z | xargs -0 git rm
```

## Steam

```sh
# setup steam container
sudo ./mkarch.sh steam
# enable updates with fish pp function
sudo echo "permit root" >> /var/lib/machines/steam/etc/doas.conf

# enter container then inside uncomment multilib repo and ParallelDownloads=5
steam.sh
doas busybox vi /etc/pacman.conf

# add links to required bins
doas ln -s /bin/busybox /usr/local/bin/gzip
doas ln -s /bin/busybox /usr/local/bin/less
doas ln -s /bin/busybox /usr/local/bin/lspci
doas ln -s /bin/busybox /usr/local/bin/pgrep

# install general deps
doas pacman -Sy lib32-systemd ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji xdg-user-dirs
# install AMD GPU deps
doas pacman -Sy xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon lib32-mesa gstreamer lib32-gstreamer libva-mesa-driver lib32-libva-mesa-driver
# install steam
doas pacman -Sy steam

# optionally install paru
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si

# optionally install protontricks (AUR)
paru -S protontricks

# create a launcher script
touch steam.sh && chmod 700 steam.sh && busybox vi steam.sh
```
```sh
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
/usr/bin/steam $@
```

## Lutris

```sh
# setup lutris container
sudo ./mkarch.sh lutris

# enter container then inside uncomment multilib repo and ParallelDownloads=5
lutris.sh
doas busybox vi /etc/pacman.conf

# add links to required bins
cd /usr/local/bin
doas ln -s /bin/busybox /usr/local/bin/lspci

# install general deps
doas pacman -Sy lib32-systemd ttf-liberation xdg-desktop-portal-gtk wine lutris
# install AMD GPU deps
doas pacman -Sy xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon lib32-mesa gstreamer lib32-gstreamer libva-mesa-driver lib32-libva-mesa-driver vulkan-tools

# create a launcher script
touch lutris.sh && chmod 700 lutris.sh && busybox vi lutris.sh
```
```sh
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
/usr/bin/lutris $@
```