function dup --description 'Update all docker images'
  docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}'| grep -v "local/" | xargs -L1 docker pull
end
