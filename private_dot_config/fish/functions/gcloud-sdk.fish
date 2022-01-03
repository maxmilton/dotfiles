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
    --mount src=gcloud-sdk,dst=/google-cloud-sdk \
    ghcr.io/maxmilton/gcloud $argv
end
