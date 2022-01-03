# https://github.com/maxmilton/dockerfiles/tree/master/gcloud

function gcloud-sdk --description 'Google Cloud SDK'
  # Authenticate on first run
  if not docker volume inspect gcloud-config >/dev/null 2>&1
    docker volume create gcloud-config

    docker run --rm -ti \
      --mount src=gcloud-config,dst=/home/gcloud \
      ghcr.io/maxmilton/gcloud gcloud auth login
  end

  docker run --rm -ti \
    --mount src=gcloud-config,dst=/home/gcloud \
    --mount type=bind,src="$PWD",dst=/data \
    --env LANGUAGE=en \
    --env LANG=C \
    --env LC_MESSAGES=C \
    ghcr.io/maxmilton/gcloud $argv
end
