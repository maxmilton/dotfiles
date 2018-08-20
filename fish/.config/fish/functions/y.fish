function y -d 'Run yarn dev script (default) or another script'
  if test -z $argv[1]
    yarn run start; or yarn run dev
  else
    yarn run $argv
  end
end
