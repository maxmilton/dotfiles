function dbox -d 'Dockerized dev box with persistence'
  if docker container inspect dbox >/dev/null 2>&1
    if test (docker inspect -f '{{.State.Running}}' dbox) != 'true'
      docker start dbox
    end
    docker exec -ti dbox entrypoint.sh $argv
  else
    # no previous dbox container exists; first-time run
    docker run -ti \
      --name dbox \
      --volume ~/Development/dotfiles/fish/dbox-entrypoint.sh:/usr/bin/entrypoint.sh \
      --entrypoint entrypoint.sh \
      alpine:edge $argv
  end
end
