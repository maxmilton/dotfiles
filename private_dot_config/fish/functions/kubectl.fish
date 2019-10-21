# https://github.com/MaxMilton/dockerfiles/tree/master/gcloud

function kubectl --description 'kubectl via Google Cloud SDK'
  docker run --rm -ti --volumes-from gcloud-config local/gcloud kubectl $argv
end
