function dti --description 'list all tags for a Docker image on a remote registry'
  curl -s 'https://registry.hub.docker.com/v1/repositories/'$argv[1]'/tags' | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'
end
