function pp
  set -l normal (set_color normal)
  set -l yellow (set_color --bold bryellow)

  echo -e "$yellow""Updating system...""$normal"
  paru -Syu

  echo -e "$yellow""Updating brave container""$normal"
  paru -Syur /home/max/.machines/brave

  # echo -e "$yellow""Updating code container""$normal"
  # paru -Syur /home/max/.machines/code

  echo -e "$yellow""Updating librewolf container""$normal"
  paru -Syur /home/max/.machines/librewolf
  # paru -Sr /home/max/.machines/librewolf librewolf-bin --nodeps

  echo -e "$yellow""Updating vms container""$normal"
  sudo pacman -Syur /home/max/.machines/vms

  echo -e "$yellow""Updating arch container""$normal"
  sudo pacman -Syur /var/lib/machines/arch

  # echo -e "$yellow""Updating alpine container""$normal"
  # sudo systemd-nspawn -D /var/lib/machines/alpine sh -c "apk upgrade"

  # echo -e "$yellow""Updating lutris container""$normal"
  # sudo systemd-nspawn -D /var/lib/machines/lutris sh -c "pacman -Syu"

  echo -e "$yellow""Updating steam container""$normal"
  sudo systemd-nspawn -D /var/lib/machines/steam sh -c "paru -Syu"

  echo -e "$yellow""Updating system firmware...""$normal"
  fwupdmgr refresh && sudo fwupdmgr update
end
