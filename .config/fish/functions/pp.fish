function __pp_msg
    set_color --bold bryellow
    printf '%s\n' (string join ' ' -- $argv)
    set_color normal
end

function pp
    if ! isatty stdout
        echo 'Must be run with stdout attached to a terminal, exiting'
        return 1
    end

    __pp_msg 'Updating system...'
    paru -Syu; or return

    if test -d /home/max/.machines/brave
        __pp_msg 'Updating brave container'
        paru -Su \
            --root /home/max/.machines/brave \
            --cachedir /var/cache/pacman/pkg; or return
    end

    # if test -d /home/max/.machines/librewolf
    #     __pp_msg 'Updating librewolf container'
    #     paru -Su \
    #         --root /home/max/.machines/librewolf \
    #         --cachedir /var/cache/pacman/pkg; or return
    #     paru -S \
    #         --root /home/max/.machines/librewolf \
    #         --cachedir /var/cache/pacman/pkg \
    #         --needed --nodeps librewolf-bin; or return
    # end

    if test -d /home/max/.machines/chrome
        __pp_msg 'Updating chrome container'
        paru -Su \
            --root /home/max/.machines/chrome \
            --cachedir /var/cache/pacman/pkg; or return
    end

    if test -d /home/max/.machines/dev
        __pp_msg 'Updating dev container'
        paru -Su \
            --root /home/max/.machines/dev \
            --cachedir /var/cache/pacman/pkg; or return
    end

    # if test -d /home/max/.machines/vms
    #     __pp_msg 'Updating vms container'
    #     sudo paru -Su \
    #         --sysroot /home/max/.machines/vms \
    #         --cachedir /var/cache/pacman/pkg; or return
    # end

    # if test -d /var/lib/machines/game
    #     __pp_msg 'Updating game container (lutris, steam)'
    #     sudo paru -Su \
    #         --sysroot /var/lib/machines/game \
    #         --cachedir /var/cache/pacman/pkg; or return
    # end

    if test -d /var/lib/machines/cachyos
        __pp_msg 'Updating cachyos container'
        # HACK: Persistently set DisableSandbox until paru supports --disable-sandbox flag.
        sudo sed -i 's/^#DisableSandbox$/DisableSandbox/' /var/lib/machines/cachyos/etc/pacman.conf; or return
        sudo paru -Syu \
            --sysroot /var/lib/machines/cachyos \
            --cachedir /var/cache/pacman/pkg; or return
    end

    if test -d /var/lib/machines/alpine
        __pp_msg 'Updating alpine container'
        sudo systemd-nspawn --capability=CAP_IPC_LOCK -D /var/lib/machines/alpine sh -c 'apk upgrade'; or return
    end

    if command -q claude
        __pp_msg 'Updating AI: claude'
        claude upgrade; or return
    end

    if command -q amp
        __pp_msg 'Updating AI: amp'
        amp update; or return
    end

    if command -q grok
        __pp_msg 'Updating AI: grok'
        grok update; or return
    end

    if command -q codex
        __pp_msg 'Updating AI: codex'
        codex update; or return
    end

    __pp_msg 'Updating system firmware...'
    fwupdmgr refresh
    sudo fwupdmgr update; or return
end
