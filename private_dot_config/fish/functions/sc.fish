function sc --description 'Run systemctl'
  if test (id -u) -ne 0
    sudo systemctl $argv
  else
    systemctl $argv
  end
end
