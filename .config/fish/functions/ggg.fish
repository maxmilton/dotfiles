function ggg --description 'Interactive git switch branch'
    set -l branch (
        git branch --color=always --no-column --sort=-committerdate |
        fzy --lines=max --query="$argv"
    )
    or return

    set branch (string replace -ra '^[*+ ] |\x1b\[[0-?]*[ -/]*[@-~]' '' -- "$branch")

    git switch --merge -- "$branch"
end
