function ziz --description 'Run zizmor CI/CD static analyzer'
    set -l token (gh auth token)
    or return

    if not set -q argv[1]
        set argv .
    end

    zizmor --gh-token="$token" --persona=auditor --strict-collection $argv
end
