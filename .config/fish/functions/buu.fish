function buu --description "Update bun dependencies interactively"
    env BUN_CONFIG_VERBOSE_FETCH='' bunx --bun taze \
        --recursive \
        --include-locked \
        --interactive \
        --write \
        --no-install \
        --ignore-paths='**/*.bak/**' \
        latest $argv
end
