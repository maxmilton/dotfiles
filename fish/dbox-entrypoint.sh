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

  # set dbox user
  addgroup -g 6805 -S dbox
  adduser -D -u 6805 -S -h /home/dbox -s /usr/bin/fish -G dbox dbox
  addgroup dbox wheel

  # create group with host user gid if one doesn't already exist
  if ! getent group "$GID" >/dev/null 2>&1; then
    addgroup -g "$GID" -S hostgrp
  fi
  # add user to group for access permissions to host user home files
  addgroup dbox $(getent group "$GID" | cut -d: -f1)

  # allow dbox user to write to /dev/stderr
  mkfifo -m 600 /tmp/logpipe
  chown dbox:dbox /tmp/logpipe
  cat <> /tmp/logpipe 1>&2 &

  # install base deps
  apk add --update \
    curl \
    fish \
    git \
    man \
    mdocml-apropos \
    sudo
    # man-pages \
    # less \
    # less-doc \
    # util-linux pciutils usbutils coreutils binutils findutils grep \

  # no password sudo access
  echo -e "%wheel\\tALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

  mkdir -p ~/.config/fish

  # write fish shell config file for root user
  cat > ~/.config/fish/config.fish <<'EOF'
set -U fish_path /home/dbox/.config/fish
set -U fisher_config /home/dbox/.config/fisherman
set -U fisher_cache /home/dbox/.cache/fisherman

for file in $fish_path/conf.d/*.fish
  builtin source $file 2> /dev/null
end

set fish_function_path $fish_path/functions $fish_function_path
set fish_complete_path $fish_path/completions $fish_complete_path
EOF

  # install fisherman
  curl -Lo /home/dbox/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher

  # set up fish functions
  git clone --depth 1 https://github.com/MaxMilton/dotfiles.git /home/dbox/.dotfiles
  ln -s /home/dbox/.dotfiles/fish/.config/fish/functions/* /home/dbox/.config/fish/functions/

  # set correct permissions
  chown -R dbox:dbox /home/dbox

  # install fisherman plugins
  sudo -u dbox fish -c 'fisher MaxMilton/pure'

  # compile fish config
  sudo -u dbox fish /home/dbox/.dotfiles/fish/.config/fish/onetime-config.fish

  # change root shell
  sed -i -- 's/root:\/bin\/ash/root:\/usr\/bin\/fish/' /etc/passwd

  echo '0' > /first-run
else
  # update dot files (in the background)
  nohup git -C /home/dbox/.dotfiles pull --update-shallow &>/dev/null &
fi

# allow docker '--user' argument or run as root if commands are passed in
if [ "$(id -u)" != 0 ] || [ -n "$*" ]; then
  exec fish -c "$*"
fi

exec sudo -u dbox -i
