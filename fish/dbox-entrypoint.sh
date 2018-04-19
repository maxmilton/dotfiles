#!/bin/sh

set -e

#
# Bootstrap Dev Box Environment
#
# Docker container for quick experiments and protptyping. See dbox.fish for
# init function.
#

echo "  __  __"
echo " /\\ \\/\\ \\"
echo " \\_\\ \\ \\ \\____    ___   __  _"
echo " /'_\` \\ \\ '__\`\\  / __\`\\/\\ \\/'\\"
echo "/\\ \\L\\ \\ \\ \\L\\ \\/\\ \\L\\ \\/>  </"
echo "\\ \\___,_\\ \\_,__/\\ \\____//\\_/\\_\\"
echo " \\/__,_ /\\/___/  \\/___/ \\//\\/_/"
echo ""

if ! command -v fish >/dev/null 2>&1; then
  echo "New dbox, running first-time setup..."
  echo ""

  # install base deps
  apk add --update \
    curl \
    fish \
    git

  # install fisherman
  curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher

  # install fisherman plugins
  fish -c 'fisher MaxMilton/pure'

  # precompile fish config
  fish /config.fish

  # reset $PATH additions
  fish -c 'set -e fish_user_paths'

  # set up fish functions
  git clone --depth 1 https://github.com/MaxMilton/dotfiles.git /usr/local/dotfiles
  ln -s /usr/local/dotfiles/fish/.config/fish/functions/* /root/.config/fish/functions/
fi

exec fish
