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
# verify and repair git repo integrity (do after changing file permissions!)
git fsck
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

```sh
# local http server
busybox httpd -fvp 5000 -h .
```

```sh
# Clearing PageCache
sudo sync; echo 1 > /proc/sys/vm/drop_caches
# Clearing Dentries and Inodes
sudo sync; echo 2 > /proc/sys/vm/drop_caches
# Clearing PageCache, Dentries, and Inodes
sudo sync; echo 3 > /proc/sys/vm/drop_caches
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
doas pacman -Sy lib32-systemd ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji xdg-user-dirs tar
# install AMD GPU deps
doas pacman -Sy xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon lib32-mesa gstreamer lib32-gstreamer libva-mesa-driver lib32-libva-mesa-driver
# OR install Intel GPU deps
doas pacman -Sy xf86-video-intel intel-compute-runtime intel-media-driver intel-media-sdk onevpl-intel-gpu vulkan-intel lib32-vulkan-intel lib32-mesa gstreamer lib32-gstreamer libva-mesa-driver lib32-libva-mesa-driver
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

## Steam patch

```sh
# Get steam app ID (e.g., 828070 in the below script)
protontricks -l
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
protontricks --command "wine '/home/max/Downloads/xxxx.exe'" 828070
```

## Lutris

```sh
# setup lutris container
sudo ./mkarch.sh lutris

# enter container then inside uncomment multilib repo and ParallelDownloads=5
lutris.sh
doas busybox vi /etc/pacman.conf

# add links to required bins
doas ln -s /bin/busybox /usr/local/bin/lspci
doas ln -s /bin/busybox /usr/local/bin/sed

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

## Jellyfin

```sh
# setup lutris container
sudo ./mkarch.sh jellyfin

# add links to required bins
doas ln -s /bin/busybox /usr/local/bin/lspci
doas ln -s /bin/busybox /usr/local/bin/gzip
doas ln -s ~/Projects/dotfiles/.local/bin/sudo /usr/local/bin/sudo

# install paru deps
doas pacman -S binutils fakeroot git

# install paru
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si

# install jellyfin deps and Intel GPU deps
paru -S jellyfin-bin jellyfin-ffmpeg6-bin yt-dlp tar intel-compute-runtime intel-media-driver intel-media-sdk onevpl-intel-gpu vulkan-intel

doas systemctl enable jellyfin.service
doas systemctl start jellyfin.service

# Open in browser:
# http://192.168.1.222:8096/

# create a launcher script (on the server, not in the container)
touch jellyfin.sh && chmod 700 jellyfin.sh && busybox vi jellyfin.sh
```
```sh
#!/bin/sh -eu

if test ! -z "$(machinectl show --property=State=running jellyfin 2>&-)"; then
  sudo systemd-run \
    --machine=jellyfin \
    --uid=max \
    --gid=max \
    --shell
else
  sudo systemd-nspawn \
    --bind=/dev/dri/card0 \
    --bind=/dev/dri/renderD128 \
    --bind=/home/max/Downloads \
    --bind=/mnt/e5fee00f-45f8-4c23-88fb-c8a1f67aa9e1/Store:/media \
    --overlay=/home/max/Projects::/home/max/Projects \
    --directory=/var/lib/machines/jellyfin \
    --boot
fi
```

## Gitea

```sh
sudo ./mkarch.sh gitea

doas pacman -S git gitea openssh

doas systemctl enable gitea.service
doas systemctl start gitea.service
```

`~/.local/bin/gitea.sh`:

```sh
#!/bin/sh -eu

if test ! -z "$(machinectl show --property=State=running gitea 2>&-)"; then
  sudo systemd-run \
    --machine=gitea \
    --uid=max \
    --gid=max \
    --shell
else
  sudo systemd-nspawn \
    --bind=/home/max/Downloads \
    --bind=/home/max/Projects \
    --directory=/var/lib/machines/gitea \
    --boot
fi
```

<!--
## Erigon

```sh
#!/bin/sh -eu

# monitor and respawn until exit 0
until /usr/local/bin/erigon \
  --chain=mainnet \
  --datadir=/home/eth/erigon-data \
  --ethash.dagdir=/home/eth/erigon-data/dag \
  --internalcl \
  --torrent.upload.rate=1mb \
  --txpool.disable \
  --private.api.addr=0.0.0.0:9090 \
  --http.addr=0.0.0.0 \
  --http.vhosts=any \
  --http.corsdomain='*' \
  --http.compression=false \
  --ws \
  --ws.compression=false; do
    echo -e "\e[1;31merigon crashed with exit code $?. Respawning...\e[0m" >&2
    sleep 1
done

  # --torrent.upload.rate=1kb \
  # --http.api=eth,erigon,web3,net,debug,trace,txpool \
  # --authrpc.addr=0.0.0.0 \
  # --authrpc.vhosts=any \

# TODO: Don't disable TX pool?

# https://github.com/ledgerwatch/erigon/discussions/6369
# https://github.com/ledgerwatch/erigon#multiple-instances--one-machine
# https://github.com/ledgerwatch/erigon/blob/devel/docker-compose.yml
```

RPC only via main bin:
```sh
#!/bin/sh -eu
/usr/local/bin/erigon \
  --chain=mainnet \
  --datadir=/home/eth/erigon-data \
  --ethash.dagdir=/home/eth/erigon-data/dag \
  --torrent.upload.rate=1kb \
  --txpool.disable \
  --sync.loop.throttle=24h \
  --private.api.addr=0.0.0.0:9090
```

RPC only:
```sh
#!/bin/sh -eu

# monitor and respawn until exit 0
until /usr/local/bin/rpcdaemon \
  --chain=mainnet \
  --datadir=/home/eth/erigon-data \
  --ethash.dagdir=/home/eth/erigon-data/dag \
  --private.api.addr=0.0.0.0:9090; do
    echo -e "\e[1;31merigon rpcdaemon crashed with exit code $?. Respawning...\e[0m" >&2
    sleep 1
done
```
-->

## Dev (container)

`~/vscode.sh`:

```sh
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XAUTHORITY=/home/max/.Xauthority
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark

unset SSH_AGENT_PID
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)
eval $(gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)

while ! test -S "$XDG_RUNTIME_DIR/bus"; do
  sleep 1
done

systemctl --user start gpg-agent.service
dbus-update-activation-environment --systemd --all

# /usr/bin/code --password-store="gnome" --enable-features=UseOzonePlatform --ozone-platform=wayland --verbose --vmodule="*/components/os_crypt/*=1"
/usr/bin/code --password-store="gnome" --enable-features=UseOzonePlatform --ozone-platform=wayland
```

`~/seahorse.sh`:

```sh
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XAUTHORITY=/home/max/.Xauthority
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark

# export GNOME_KEYRING_CONTROL="$XDG_RUNTIME_DIR"/keyring
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR"/keyring/ssh

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)
eval $(gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
while ! test -S "$XDG_RUNTIME_DIR/bus"; do sleep 1; done

systemctl --user start gpg-agent.service
dbus-update-activation-environment --systemd --all

/usr/bin/seahorse
```

`~/.config/fish/conf.d/init.fish`:

```sh
status is-interactive || exit

set -gx COLORTERM truecolor
set -gx TERM xterm-256color
set -g hydro_color_prompt magenta
# set -e SSH_AGENT_PID
set -g -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
set -g -x GPG_TTY (tty)
# while ! test -S "$XDG_RUNTIME_DIR"bus; sleep 1; end
systemctl --user start gpg-agent.service
dbus-update-activation-environment --systemd --all
```

## bettercap

```sh
doas pacman -S --noconfirm bettercap && touch bettercap-web.sh && chmod +x bettercap-web.sh && busybox vi bettercap-web.sh
```

`bettercap-cli.sh`:

```sh
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
doas /usr/bin/bettercap $@
```

`bettercap-web.sh`:

```sh
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
test ! -d /usr/share/bettercap \
  && doas /usr/bin/bettercap -eval "caplets.update; ui.update; q"
doas /usr/bin/bettercap -caplet http-ui
```

## Bun build environment

<https://bun.sh/docs/project/contributing>

`setup-bun-dev-env.sh`:

```sh
#!/bin/sh -eu
doas pacman -S --noconfirm --needed archlinux-keyring
doas pacman-key --init
doas pacman-key --populate archlinux
doas pacman -S --noconfirm --needed base-devel ccache cmake git go libiconv libtool make ninja pkg-config python rust sed unzip ruby
doas pacman -S --noconfirm --needed llvm clang lld
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
bun setup
build/bun-debug --version

# bun run build
# bun run build:release
```

---

# Reth Notes

```sh
rustup update
```

## Reth

<https://paradigmxyz.github.io/reth/installation/source.html>

Faster build:

```sh
cargo build --release
```

Absolute best performance bin:

```sh
RUSTFLAGS="-C target-cpu=native" cargo build --profile maxperf --features jemalloc,asm-keccak
```

## Lighthouse

<https://lighthouse-book.sigmaprime.io/installation-source.html>

```sh
PROFILE=maxperf FEATURES=jemalloc make
```
