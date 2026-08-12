function ggpp --description 'Git pull all immediate subdirs'
    for dir in */
        if test -d "$dir/.git"
            echo "==> $dir"
            git -C "$dir" pull
        end
    end
end
