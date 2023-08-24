function pp
  paru -Syu
  paru -Syur "$HOME"/machines/brave
  paru -Syur "$HOME"/machines/librewolf
  # paru -Sr "$HOME"/machines/librewolf librewolf-bin --nodeps
  sudo pacman -Syur /var/lib/machines/arch
  sudo systemd-nspawn -D /var/lib/machines/lutris sh -c "pacman -Syu"
  sudo systemd-nspawn -D /var/lib/machines/steam sh -c "paru -Syu"
  # fwupdmgr refresh && sudo fwupdmgr update
end
