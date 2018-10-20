function up_yarn -d 'Update global yarn packages'
  if type --quiet yarn
    set --local yarn_global_dir "$HOME"/.config/yarn/global

    if test -d $yarn_global_dir
      pushd $yarn_global_dir
      # do install to update `yarn.lock` in case `package.json` has changed
      yarn install
      popd

      # do the actual upgrades
      yarn global upgrade --save &
      set --local PID %last
      echo "Updating yarn global packages in background with PID" "$PID"
    else
      echo "Yarn global directory not found;" "$yarn_global_dir"
    end
  end
end
