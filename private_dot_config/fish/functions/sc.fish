function sc --description 'Run systemctl'
  if test (id -u) -ne 0
    sudo systemctl
  else
    systemctl
  end
end
