function y -d 'Run yarn dev script (default) or another script'
  if test -z $argv[1]
    yarn run dev; or yarn run start
  else
    yarn run $argv
  end
end
