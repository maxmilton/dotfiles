function buu --description "Update bun dependencies interactively"
    set -l maturity_period 7
    if contains -- -f $argv
        set maturity_period 0
    end

    env BUN_CONFIG_VERBOSE_FETCH='' bunx --bun taze \
        --recursive \
        --include-locked \
        --interactive \
        --write \
        --no-install \
        --github-actions-style=sha \
        --ignore-paths='**/*.bak/**' \
        --maturity-period=$maturity_period \
        --maturity-period-exclude='@ekscss/*,@maxmilton/*,bugbox,bun-duckdb,*ekscss,stage1' \
        latest $argv
end
