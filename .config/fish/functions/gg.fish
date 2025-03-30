function gg
    set -l branch (git branch --all --format "%(refname:lstrip=2)" | fzy --lines max --query="$argv")
    if test -n "$branch"
        git switch "$branch"
    else
        return 1
    end
end
