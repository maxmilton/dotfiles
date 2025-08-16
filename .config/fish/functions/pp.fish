function msg
    set_color --bold bryellow
    echo "$argv"
    set_color normal
end

function pp
    if ! isatty stdout
        echo "Must be run in an interactive shell, exiting"
        return 1
    end

    and msg 'Updating system...'
    and paru -Syu

    and msg 'Updating brave container'
    and paru -Su \
        --root /home/max/.machines/brave \
        --cachedir /var/cache/pacman/pkg

    # and msg 'Updating librewolf container'
    # and paru -Su \
    #     --root /home/max/.machines/librewolf \
    #     --cachedir /var/cache/pacman/pkg
    # and paru -S \
    #     --root /home/max/.machines/librewolf \
    #     --cachedir /var/cache/pacman/pkg \
    #     --needed --nodeps librewolf-bin

    # and msg 'Updating chrome container'
    # and paru -Su \
    #     --root /home/max/.machines/chrome \
    #     --cachedir /var/cache/pacman/pkg

    # and msg 'Updating dev container'
    # and paru -Su \
    #     --root /home/max/.machines/dev \
    #     --cachedir /var/cache/pacman/pkg

    # and msg 'Updating vms container'
    # and sudo paru -Su \
    #     --sysroot /home/max/.machines/vms \
    #     --cachedir /var/cache/pacman/pkg

    # and msg 'Updating game container (lutris, steam)'
    # and sudo paru -Su \
    #     --sysroot /var/lib/machines/game \
    #     --cachedir /var/cache/pacman/pkg

    and msg 'Updating cachyos container'
    and sudo paru -Syu \
        --sysroot /var/lib/machines/cachyos \
        --cachedir /var/cache/pacman/pkg

    # and msg 'Updating alpine container'
    # and sudo systemd-nspawn --capability=CAP_IPC_LOCK -D /var/lib/machines/alpine sh -c "apk upgrade"

    and msg 'Updating system firmware...'
    and fwupdmgr refresh
    and sudo fwupdmgr update
end
