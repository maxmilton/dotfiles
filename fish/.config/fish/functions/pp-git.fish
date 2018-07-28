function pp-git -d 'Update git repos'
  # update my forked repos
  for dir in $HOME/Development/0__github_forks/*/
    echo -e "\n\033[1;36m$dir\033[0m"
    git -C $dir fetch upstream
    and git -C $dir merge upstream/master master
    and git -C $dir push origin master
  end

  # update cloned repos
  for dir in $HOME/Development/0__github_clones/*/
    echo -e "\n\033[1;36m$dir\033[0m"
    git -C $dir pull --prune
  end
end
