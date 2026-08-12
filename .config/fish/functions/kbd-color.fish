function kbd-color --description "Set keyboard backlight color"
    set -l color

    if test (count $argv) -gt 0
        set color $argv[1]
    else
        set color (kcolorchooser --print)
    end

    test -n "$color"
    or return

    busctl --system call \
        org.kde.kameleon.qmk.helper \
        /org/kde/kameleon/qmk/helper \
        org.kde.kameleon.qmk.helper \
        ApplyColor s $color
end
