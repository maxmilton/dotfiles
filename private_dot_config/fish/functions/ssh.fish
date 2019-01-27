# prevent lang issues on remote servers
function ssh
  env LANGUAGE=en LANG=C LC_MESSAGES=C ssh $argv
end
