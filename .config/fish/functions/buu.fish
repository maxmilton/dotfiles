function buu --description "Update bun dependencies interactively"
    env BUN_CONFIG_VERBOSE_FETCH='' bunx --bun taze \
        --recursive \
        --include-locked \
        --interactive \
        --write \
        --no-install \
        --ignore-paths='**/*.bak/**' \
        --maturity-period=7 \
        --maturity-period-exclude='@maxmilton/*,bugbox,stage1' \
        latest $argv
end
