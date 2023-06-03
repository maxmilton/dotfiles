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
if test (uname -s) = "Darwin"
  fish_add_path "$HOME"/.nix-profile/bin /nix/var/nix/profiles/default/bin
end

# Set user paths in reverse order of priority
fish_add_path "$HOME"/.foundry/bin

fish_add_path "$HOME"/.local/share/pnpm
set -U PNPM_HOME "$HOME"/.local/share/pnpm

fish_add_path "$HOME"/.bun/bin
set -U BUN_INSTALL "$HOME"/.bun
set -Ux DO_NOT_TRACK 1

fish_add_path "$HOME"/.local/bin
