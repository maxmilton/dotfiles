function up_yarn -d 'Update global yarn packages'
  if type --quiet yarn
    # run install first in case `package.json` has changed
    begin; cd "$HOME"/.config/yarn/global; and yarn install; end

    # do the actual upgrades
    yarn global upgrade --save &
    set --local PID %last
    echo "Updating yarn global packages in background with PID" "$PID"
  end
end
