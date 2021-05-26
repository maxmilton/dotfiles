#!/bin/sh
set -euo pipefail

# Bootstrap Dev Box Environment
#
# Minimal docker container with loose persistence for quick experiments and
# protptyping. Luncher script function in: ./config/fish/functions/dbox.fish
#

cat <<'EOF'
  __  __
 /\ \/\ \
 \_\ \ \ \____    ___   __  _
 /'_` \ \ '__`\  / __`\/\ \/'\
/\ \L\ \ \ \L\ \/\ \L\ \/>  </
\ \___,_\ \_,__/\ \____//\_/\_\
 \/__,_ /\/___/  \/___/ \//\/_/

EOF

reset='\e[0m'
yellow_bold='\e[1;93m'

if [ ! -f /first-run ]; then
  echo -e "${yellow_bold}New dbox, running first-time setup...${reset}\\n"
  set -x

  # set dbox user
  addgroup -g 6805 -S dbox
  adduser -D -u 6805 -S -h /home/dbox -s /usr/bin/fish -G dbox dbox
  addgroup dbox wheel

  # create group with host user gid if one doesn't already exist
  if ! getent group "$GID" >/dev/null 2>&1; then
    addgroup -g "$GID" -S hostgrp
  fi
  # add user to group for access permissions to host user home files
  addgroup dbox "$(getent group "$GID" | cut -d: -f1)"

  # allow dbox user to write to /dev/stderr
  mkfifo -m 600 /tmp/logpipe
  chown dbox:dbox /tmp/logpipe
  cat <> /tmp/logpipe 1>&2 &

  # install base deps + tools
  apk add --update \
    curl \
    docker \
    docs \
    exa \
    fd \
    fish \
    git \
    less \
    man-pages \
    mandoc-apropos \
    sudo
    # replacements for busybox built-ins
    #binutils coreutils findutils grep pciutils usbutils util-linux
    #bat

  # install glibc
  # apk add ca-certificates wget
  # wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
  # wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-2.33-r0.apk
  # apk add glibc-*.apk

  # no password sudo access
  echo -e "%wheel\\tALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

  # install fisher and plugins
  sudo -u dbox -i fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
  sudo -u dbox -i fish -c 'fisher install jorgebucaran/autopair.fish'
  sudo -u dbox -i fish -c 'fisher install jorgebucaran/hydro'

  # install dotfiles
  sudo -u dbox BINDIR=/home/dbox/bin sh -c "$(curl -fsLS git.io/chezmoi)" -- init maxmilton --depth 0 --apply

  # compile fish config
  sudo -u dbox -i fish /home/dbox/.config/fish/oneshot-config.fish

  # set correct permissions
  chown -R dbox:dbox /home/dbox

  echo '1' > /first-run
  set +x
  echo -e "\\n${yellow_bold}First-time setup finished. Welcome to dbox!${reset}\\n"
  printf '\a'
else
  # # FIXME: After this compile the fish config again
  # # update dot files (in the background)
  # nohup git -C /home/dbox/.dotfiles pull --update-shallow &>/dev/null &
  echo -e "${yellow_bold}All your base are belong to us.${reset}\\n"
fi

# overwrite fish config file
cat > /home/dbox/.config/fish/config.fish <<'EOF'
set -x GPG_TTY (tty)
set -U hydro_color_prompt
set -U PAGER 'less'
alias docker 'sudo docker'
EOF

# allow docker '--user' argument or run as root if commands are passed in
if [ "$(id -u)" != 0 ] || [ -n "$*" ]; then
  exec fish -c "$*"
fi

exec sudo -u dbox -i
