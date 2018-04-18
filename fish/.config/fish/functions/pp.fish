function pp -d 'Get system package updates'
  switch (awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')
    case "Arch Linux"
      yaourt -Syu --aur $argv
    case Fedora
      sudo dnf update --refresh -y
    case Debian Ubuntu
      sudo apt update; and sudo apt-get upgrade -y
    case "Alpine Linux"
      apk upgrade --update-cache
  end
end
