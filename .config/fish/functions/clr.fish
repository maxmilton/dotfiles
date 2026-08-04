function clr
    printf "\x1Bc"

    # Clear scrollback buffer on macOS
    printf '\x1B[2J\x1B[3J\x1B[H'
end
