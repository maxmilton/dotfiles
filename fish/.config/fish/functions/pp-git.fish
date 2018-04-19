function pp-git -d 'Update git repos'
  # Run in sub-shell so the `cd` doesn't effect the active shell
  fish -c "cd $HOME/Development/0__github_projects; and gll"
end
