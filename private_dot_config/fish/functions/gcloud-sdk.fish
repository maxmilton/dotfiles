# https://github.com/maxmilton/dockerfiles/tree/master/gcloud

function gcloud-sdk --description 'Google Cloud SDK'
  # Authenticate on first run
  if not docker volume inspect gcloud-config >/dev/null 2>&1
    docker volume create gcloud-config

    docker run --rm -ti \
      --mount src=gcloud-config,dst=/home/gcloud \
      ghcr.io/maxmilton/gcloud gcloud auth login

    # docker run --rm -ti \
    #   --mount src=gcloud-config,dst=/home/gcloud \
    #   ghcr.io/maxmilton/gcloud /bin/bash -c 'gcloud auth login && gcloud config set core/disable_usage_reporting true && gcloud config set component_manager/disable_update_check true && gcloud config set survey/disable_prompts true'

    # docker run --rm -ti \
    #   --mount src=gcloud-config,dst=/home/gcloud \
    #   gcloud config set core/disable_usage_reporting true

    # docker run --rm -ti \
    #   --mount src=gcloud-config,dst=/home/gcloud \
    #   gcloud config set component_manager/disable_update_check true

    # docker run --rm -ti \
    #   --mount src=gcloud-config,dst=/home/gcloud \
    #   gcloud config set survey/disable_prompts true
  end

  docker run --rm -ti \
    --mount src=gcloud-config,dst=/home/gcloud \
    --mount type=bind,src="$PWD",dst=/data \
    --env LANGUAGE=en \
    --env LANG=C.UTF-8 \
    --env LC_MESSAGES=C \
    ghcr.io/maxmilton/gcloud $argv
end
