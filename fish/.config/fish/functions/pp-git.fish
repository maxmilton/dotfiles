function pp-git -d 'Update git repos'
  function echo-info -d 'Print information about a git repo'
    set -l dir $argv[1]
    set -l reset (set_color normal)
    echo -s (set_color --bold cyan) '📂 ' $dir $reset
    echo -s (set_color yellow) '🔖 ' (git -C $dir rev-parse --abbrev-ref HEAD) $reset
  end

  # update my forked repos
  for dir in $HOME/Development/0__github_forks/*/
    echo-info $dir
    git -C $dir fetch upstream
    and git -C $dir merge upstream/master master
    and git -C $dir push origin master
  end

  # update cloned repos
  for dir in $HOME/Development/0__github_clones/*/
    echo-info $dir
    git -C $dir pull --prune
  end
end
