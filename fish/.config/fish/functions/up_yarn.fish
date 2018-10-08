function up_yarn -d 'Update global yarn packages'
  if type -q yarn
    # run install first in case `package.json` has changed
    begin; cd "$HOME"/.config/yarn/global; and yarn install; end

    # do the actual upgrades
    yarn global upgrade --save
  end
end
