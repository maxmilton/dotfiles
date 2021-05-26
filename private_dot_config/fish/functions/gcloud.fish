# https://github.com/MaxMilton/dockerfiles/tree/master/gcloud

function gcloud --description 'Google Cloud SDK'
  # Set up auth on first run
  if not docker container inspect gcloud-config >/dev/null 2>&1
    docker run -ti --name gcloud-config local/gcloud gcloud auth login
  end

  docker run --rm -ti \
    --volumes-from gcloud-config \
    --volume="$PWD":/data \
    local/gcloud gcloud $argv
end
