function drmi -d 'Remove untagged docker images'
  docker rmi (docker images -q -f dangling=true)
end
