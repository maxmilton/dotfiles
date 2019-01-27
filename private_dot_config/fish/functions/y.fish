function y -d 'Run yarn dev script (default) or another script'
  # disable proxy (squid via net-cache in docker)
  set --local HTTP_PROXY ''
  set --local HTTPS_PROXY ''
  set --local http_proxy ''
  set --local https_proxy ''

  if test -z $argv[1]
    yarn run start; or yarn run dev
  else
    yarn run $argv
  end
end
