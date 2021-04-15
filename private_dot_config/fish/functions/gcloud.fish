# https://github.com/MaxMilton/dockerfiles/tree/master/gcloud

function gcloud --description 'Google Cloud SDK'
  docker run --rm -ti --volumes-from gcloud-config --volume="$PWD":/data local/gcloud gcloud $argv
end
