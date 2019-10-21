function up_git --description 'Update git repos'
  # Update forked repos
  for dir in $HOME/Projects/0__github_forks/*/
    git_info $dir
    git -C $dir fetch upstream
    and git -C $dir merge upstream/master master
    and git -C $dir push origin master
  end

  # Update cloned repos
  for dir in $HOME/Projects/0__github_clones/*/
    git_info $dir
    git -C $dir pull --prune
  end
end
