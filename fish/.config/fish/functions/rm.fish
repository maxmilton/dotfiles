function rm -d 'Move files into trash'
  if test (uname -s) != 'Darwin'
    # Linux
    set -l distro (awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')

    if test "$distro" = 'Alpine Linux'
      # delete immediately since Alpine is almost always CLI only
      command rm "$argv"
    else
      gio trash "$argv"
    end
  else
    # macOS
    rmtrash "$argv"
  end
end
