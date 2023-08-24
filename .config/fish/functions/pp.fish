function pp
  paru -Syu
  paru -Syur /home/max/.machines/brave
  paru -Syur /home/max/.machines/librewolf
  # paru -Sr /home/max/.machines/librewolf librewolf-bin --nodeps
  sudo pacman -Syur /var/lib/machines/arch
  sudo systemd-nspawn -D /var/lib/machines/lutris sh -c "pacman -Syu"
  sudo systemd-nspawn -D /var/lib/machines/steam sh -c "paru -Syu"
  # fwupdmgr refresh && sudo fwupdmgr update
end
