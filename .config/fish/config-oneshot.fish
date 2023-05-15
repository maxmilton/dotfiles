# FISH GLOBALS & ALIASES
#
# Fish compiles and saves these commands so they only need to be called once
# initially and after any change to this file.

# Show lines as they are read
set fish_trace 1

# update completions
fish_update_completions || true

# Reset user paths
set -U fish_user_paths

# disable welcome message
set -U fish_greeting
