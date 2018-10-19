function y -d 'Run yarn dev script (default) or another script'
  # disable proxy (squid via net-cache in docker)
  set HTTP_PROXY ''
  set HTTPS_PROXY ''
  set http_proxy ''
  set https_proxy ''

  if test -z $argv[1]
    yarn run start; or yarn run dev
  else
    yarn run $argv
  end
end
