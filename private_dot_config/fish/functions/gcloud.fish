# https://github.com/MaxMilton/dockerfiles/tree/master/gcloud

function gcloud --description 'Google Cloud SDK'
  # Set up auth on first run
  docker container inspect gcloud-config >/dev/null 2>&1
  if test $status -ne 0
    docker run -ti --name gcloud-config local/gcloud gcloud auth login
  end

  docker run \
    --rm \
    -ti \
    --volumes-from gcloud-config \
    --volume="$PWD":/data \
    local/gcloud gcloud $argv
end
