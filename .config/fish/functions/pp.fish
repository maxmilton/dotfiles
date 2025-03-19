function pp
    set -l normal (set_color normal)
    set -l yellow (set_color --bold bryellow)

    echo -e "$yellow""Updating system...""$normal"
    paru -Syu

    # echo -e "$yellow""Updating brave container""$normal"
    # paru -Syur /home/max/.machines/brave

    echo -e "$yellow""Updating zbrave container""$normal"
    paru -Syu \
        --root /home/max/.machines/zbrave \
        --dbpath /var/lib/pacman \
        --cachedir /var/cache/pacman/pkg

    # echo -e "$yellow""Updating code container""$normal"
    # paru -Syur /home/max/.machines/code

    # echo -e "$yellow""Updating librewolf container""$normal"
    # paru -Syur /home/max/.machines/librewolf
    # # paru -Sr /home/max/.machines/librewolf librewolf-bin --nodeps

    # echo -e "$yellow""Updating vms container""$normal"
    # sudo pacman -Syu \
    #     --root /home/max/.machines/vms \
    #     --dbpath /var/lib/pacman \
    #     --cachedir /var/cache/pacman/pkg

    # echo -e "$yellow""Updating arch container""$normal"
    # sudo pacman -Syur /var/lib/machines/arch

    echo -e "$yellow""Updating cachyos container""$normal"
    # sudo systemd-nspawn --capability=CAP_IPC_LOCK -D /var/lib/machines/cachyos sh -c "pacman -Syu"
    # sudo systemd-nspawn --capability=CAP_IPC_LOCK -D /var/lib/machines/cachyos sh -c "paru -Syu"
    # sudo paru -Syu \
    #     --root /var/lib/machines/cachyos \
    #     --cachedir /var/cache/pacman/pkg
    sudo paru -Syu \
        --sysroot /var/lib/machines/cachyos \
        --cachedir /var/cache/pacman/pkg

    # echo -e "$yellow""Updating alpine container""$normal"
    # sudo systemd-nspawn -D /var/lib/machines/alpine sh -c "apk upgrade"

    # echo -e "$yellow""Updating lutris container""$normal"
    # sudo systemd-nspawn --capability=CAP_IPC_LOCK -D /var/lib/machines/lutris sh -c "pacman -Syu"

    # echo -e "$yellow""Updating steam container""$normal"
    # sudo systemd-nspawn --capability=CAP_IPC_LOCK -D /var/lib/machines/steam sh -c "paru -Syu"

    echo -e "$yellow""Updating system firmware...""$normal"
    fwupdmgr refresh
    sudo fwupdmgr update
end
