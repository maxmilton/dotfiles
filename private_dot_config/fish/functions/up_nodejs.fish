function up_nodejs --description 'Update global node packages'
  if type --query pnpm
    sudo pnpm upgrade --global
  end
end
