function ssh --description 'SSH with safe lang env'
  env LANGUAGE=en LANG=C LC_MESSAGES=C ssh $argv
end
