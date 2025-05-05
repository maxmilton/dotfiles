#!/usr/bin/env fish

# NOTE: Do not use gc --prune=now, it is dangerous. Can result in corruption
# when another process is accessing the repository. Run manually if needed.

cd ~/Projects || exit

set prune (read -P "Prune? [y/N] ")

for gitdir in (fd --type d --absolute-path --hidden --exclude '*.bak' '^\.git$')
    cd $gitdir..

    set_color --bold yellow
    echo "## $(pwd)"
    set_color normal

    git fsck

    if test "$prune" = y
        git gc --aggressive
    else
        git gc --aggressive --no-prune

        set_color cyan
        git prune --expire=now --verbose --dry-run
        set_color normal
    end
end
