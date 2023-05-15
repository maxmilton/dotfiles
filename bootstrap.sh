#!/bin/sh -eu
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)

mkdir -vp ~/.config/fish/functions
mkdir -vp ~/.config/helix
mkdir -vp ~/.gnupg
mkdir -vp ~/.ssh

# export SIMPLE_BACKUP_SUFFIX=.bak

ln -vbs "${script_dir}/.config/electron-flags.conf" ~/.config/electron-flags.conf
ln -vbs "${script_dir}/.config/fish/config.fish" ~/.config/fish/config.fish
ln -vbs "${script_dir}/.config/fish/functions/bashx.fish" ~/.config/fish/functions/bashx.fish
ln -vbs "${script_dir}/.config/fish/functions/clr.fish" ~/.config/fish/functions/clr.fish
ln -vbs "${script_dir}/.config/fish/functions/gg.fish" ~/.config/fish/functions/gg.fish
ln -vbs "${script_dir}/.config/fish/functions/gl.fish" ~/.config/fish/functions/gl.fish
ln -vbs "${script_dir}/.config/fish/functions/gz.fish" ~/.config/fish/functions/gz.fish
ln -vbs "${script_dir}/.config/fish/functions/kill_process.fish" ~/.config/fish/functions/kill_process.fish
ln -vbs "${script_dir}/.config/fish/functions/lsport.fish" ~/.config/fish/functions/lsport.fish
ln -vbs "${script_dir}/.config/fish/functions/multicd.fish" ~/.config/fish/functions/multicd.fish
ln -vbs "${script_dir}/.config/fish/functions/ssh.fish" ~/.config/fish/functions/ssh.fish
ln -vbs "${script_dir}/.config/helix/config.toml" ~/.config/helix/config.toml
ln -vbs "${script_dir}/.config/helix/languages.toml" ~/.config/helix/languages.toml
ln -vbs "${script_dir}/.config/zls.json" ~/.config/zls.json
ln -vbs "${script_dir}/.gnupg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf
ln -vbs "${script_dir}/.gnupg/gpg.conf" ~/.gnupg/gpg.conf
ln -vbs "${script_dir}/.ssh/config" ~/.ssh/config
ln -vbs "${script_dir}/.curlrc" ~/.curlrc
ln -vbs "${script_dir}/.gitconfig" ~/.gitconfig
ln -vbs "${script_dir}/.gitignore" ~/.gitignore
ln -vbs "${script_dir}/.ripgreprc" ~/.ripgreprc
ln -vbs "${script_dir}/.sqliterc" ~/.sqliterc

# https://github.com/jorgebucaran/fisher#installation
# fisher install jorgebucaran/fisher
# fisher install jorgebucaran/hydro
# # fisher install jorgebucaran/replay.fish
# # fisher install jorgebucaran/nvm.fish

# fish ./.config/fish/config-oneshot.fish
# # fish ./.config/fish/__config-oneshot-dev.fish
# # fish ./.config/fish/config-oneshot-dev.fish
