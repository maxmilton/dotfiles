function dbox --description 'Dockerized dev box with persistence'
  if docker container inspect dbox >/dev/null 2>&1
    # start dbox container if it exists but is not running
    if test (docker inspect -f '{{.State.Running}}' dbox) != 'true'
      docker start dbox
    end

    if test -n "$argv"
      # run command as root
      docker exec -ti -e WORKDIR="$PWD" dbox entrypoint.sh "$argv"
    else
      # enter as dbox user
      docker exec -ti -e WORKDIR="$PWD" dbox entrypoint.sh
    end
  else
    # pull latest base image
    docker pull alpine:edge

    # no previous dbox container exists; first-time run
    docker run -ti \
      --name dbox \
      --env GID=(id -g) \
      -e WORKDIR="$PWD" \
      --volume "$HOME":'/home/'"$USER" \
      --volume "$HOME"'/.config/fish/dbox-entrypoint.sh':/usr/bin/entrypoint.sh:ro \
      --volume /var/run/docker.sock:/var/run/docker.sock \
      --entrypoint entrypoint.sh \
      alpine:edge $argv
  end
end
