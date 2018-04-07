function drm -d 'Remove stopped docker containers'
  docker rm (docker ps -a -q)
end
