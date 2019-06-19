function n -d 'Run npm dev script (default) or another script'
  # disable proxy (squid via net-cache in docker)
  set --local HTTP_PROXY ''
  set --local HTTPS_PROXY ''
  set --local http_proxy ''
  set --local https_proxy ''

  if test -z $argv[1]
    npm run start; or npm run dev
  else
    npm run $argv
  end
end
