function dup --description 'Update all docker images'
  docker images --format "{{.Repository}}:{{.Tag}}" | grep --invert-match '<none>' | xargs -L1 docker pull
end
