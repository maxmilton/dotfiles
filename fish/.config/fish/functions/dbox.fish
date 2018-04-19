function dbox -d 'Alpine dev box with persistence'
  if docker container inspect dbox >/dev/null 2>&1
    docker start -i dbox
  else
    docker run -ti \
      --name dbox \
      --volume ~/Development/dotfiles/fish/dbox-entrypoint.sh:/usr/local/bin/entrypoint.sh \
      --volume ~/Development/dotfiles/fish/.config/fish/onetime-config.fish:/config.fish \
      --entrypoint entrypoint.sh \
      alpine:edge
  end
end
