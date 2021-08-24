# https://github.com/MaxMilton/dockerfiles/tree/master/gcloud

function gsutil --description 'Google Cloud Storage SDK'
  # Set up auth on first run
  if not docker container inspect gcloud-config >/dev/null 2>&1
    docker run -ti --name gcloud-config local/gcloud gcloud auth login
  end

  docker run --rm -ti \
    --volumes-from gcloud-config \
    --volume="$PWD":/data \
    local/gcloud gsutil $argv
end
