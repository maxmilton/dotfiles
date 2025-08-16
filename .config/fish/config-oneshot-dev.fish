# FISH GLOBALS & ALIASES; EXTRAS FOR DEVELOPMENT ENVIRONMENT
#
# Fish compiles and saves these commands so they only need to be called once
# initially and after any change to this file.

# Show lines as they are read
set fish_trace 1

set -l DIR (status dirname)
source "$DIR"/config-oneshot.fish

set -U hydro_color_prompt magenta

# macOS
if test (uname -s) = Darwin and test -d "$HOME"/.nix-profile/bin
    fish_add_path "$HOME"/.nix-profile/bin /nix/var/nix/profiles/default/bin
end

# Set user paths in reverse order of priority

if test -d "$HOME"/.fly/bin
    fish_add_path "$HOME"/.fly/bin
end

if test -d "$HOME"/.cargo/bin
    fish_add_path "$HOME"/.cargo/bin
end

# if test -d "$HOME"/.cache/rebar3/bin
#     fish_add_path "$HOME"/.cache/rebar3/bin
# end

# if test -d "$HOME"/.mix/escripts
#     fish_add_path "$HOME"/.mix/escripts
# end

if test -d "$HOME"/.foundry/bin
    fish_add_path "$HOME"/.foundry/bin
end

# if test -d "$HOME/.local/share/pnpm"
#     fish_add_path "$HOME"/.local/share/pnpm
#     set -U PNPM_HOME "$HOME"/.local/share/pnpm
# end

if test -d "$HOME"/.bun/bin
    fish_add_path "$HOME"/.bun/bin
    set -U BUN_INSTALL "$HOME"/.bun
    set -U BUN_CONFIG_NO_CLEAR_TERMINAL_ON_RELOAD 1
    set -Ux BUN_CRASH_REPORTER_URL ''
end

fish_add_path "$HOME"/.local/bin

set -Ux DO_NOT_TRACK 1
set -Ux EDITOR helix
set -Ux ELECTRON_OZONE_PLATFORM_HINT auto

if test -f "$XDG_RUNTIME_DIR"/ssh-agent.socket
    set -Ux SSH_AUTH_SOCK "$XDG_RUNTIME_DIR"/ssh-agent.socket
end
