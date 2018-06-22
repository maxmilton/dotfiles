function pp-yarn -d 'Update global yarn packages'
  if type -q yarn
    yarn global upgrade --save
  end
end
