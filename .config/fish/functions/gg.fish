function gg
    set -l branch (git branch --sort=-committerdate --format "%(refname:short)" | fzy --lines max --query="$argv")
    if test -n "$branch"
        git switch "$branch"
    else
        return 1
    end
end
