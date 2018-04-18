function pp -d 'Get system package updates'
  DISTRO=(awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"')

  switch $DISTRO
    case "Arch Linux"
      yaourt -Syu --aur $argv
    case Fedora
      sudo dnf update --refresh -y
    case Ubuntu Debian
      sudo apt update && sudo apt-get upgrade -y
    case "Alpine Linux"
      apk upgrade --update-cache
  end
end
