function de --description 'Enter docker container or execute command'
  if test -z $argv[2]
    # when only passing the container id then jump into its command line
    docker exec -ti -u root $argv[1] /bin/sh -c "set -x TERM=xterm; exec sh"
  else
    docker exec $argv
  end
end
