function gll -d 'Pull git updates from sub directories'
  for dir in */
    echo -e "\n\033[1;36m$dir\033[0m"

    # run in a sub-shell
    fish -c "cd $dir; and git pull --prune"
  end
end
