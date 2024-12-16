function clr
    printf "\x1Bc"

    # clear scrollback buffer on macOS
    # printf '\x1B[3J'
    printf '\x1B[2J\x1B[3J\x1B[H'
end
