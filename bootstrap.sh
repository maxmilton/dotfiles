#!/bin/sh -eu
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)

umask 077

mkdir -vp ~/.config/fish/functions
mkdir -vp ~/.config/helix
mkdir -vp ~/.config/mpv
mkdir -vp ~/.gnupg
mkdir -vp ~/.local/bin
mkdir -vp ~/.ssh

ln -vbs "${script_dir}/.config/electron-flags.conf" ~/.config/electron-flags.conf
ln -vbs "${script_dir}/.config/fish/config.fish" ~/.config/fish/config.fish
# ln -vbs "${script_dir}/.config/fish/config-alt-aio.fish" ~/.config/fish/config.fish
ln -vbs "${script_dir}/.config/fish/functions/bashx.fish" ~/.config/fish/functions/bashx.fish
ln -vbs "${script_dir}/.config/fish/functions/clr.fish" ~/.config/fish/functions/clr.fish
ln -vbs "${script_dir}/.config/fish/functions/gg.fish" ~/.config/fish/functions/gg.fish
ln -vbs "${script_dir}/.config/fish/functions/gl.fish" ~/.config/fish/functions/gl.fish
ln -vbs "${script_dir}/.config/fish/functions/gz.fish" ~/.config/fish/functions/gz.fish
ln -vbs "${script_dir}/.config/fish/functions/kk.fish" ~/.config/fish/functions/kk.fish
ln -vbs "${script_dir}/.config/fish/functions/lsport.fish" ~/.config/fish/functions/lsport.fish
ln -vbs "${script_dir}/.config/fish/functions/multicd.fish" ~/.config/fish/functions/multicd.fish
ln -vbs "${script_dir}/.config/fish/functions/pp.fish" ~/.config/fish/functions/pp.fish
ln -vbs "${script_dir}/.config/fish/functions/ssh.fish" ~/.config/fish/functions/ssh.fish
ln -vbs "${script_dir}/.config/helix/config.toml" ~/.config/helix/config.toml
ln -vbs "${script_dir}/.config/helix/languages.toml" ~/.config/helix/languages.toml
ln -vbs "${script_dir}/.config/mpv/input.conf" ~/.config/mpv/input.conf
ln -vbs "${script_dir}/.config/mpv/mpv.conf" ~/.config/mpv/mpv.conf
ln -vbs "${script_dir}/.config/mpv/shaders" ~/.config/mpv/shaders
ln -vbs "${script_dir}/.config/zls.json" ~/.config/zls.json
ln -vbs "${script_dir}/.gnupg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf
ln -vbs "${script_dir}/.gnupg/gpg.conf" ~/.gnupg/gpg.conf
ln -vbs "${script_dir}/.local/bin/alpine.sh" ~/.local/bin/alpine.sh
ln -vbs "${script_dir}/.local/bin/arch.sh" ~/.local/bin/arch.sh
ln -vbs "${script_dir}/.local/bin/brave.sh" ~/.local/bin/brave.sh
ln -vbs "${script_dir}/.local/bin/librewolf.sh" ~/.local/bin/librewolf.sh
# ln -vbs "${script_dir}/.local/bin/sudo" ~/.local/bin/sudo
ln -vbs "${script_dir}/.local/bin/sysboot.sh" ~/.local/bin/sysboot.sh
ln -vbs "${script_dir}/.local/bin/zigup" ~/.local/bin/zigup
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
