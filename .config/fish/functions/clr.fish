function clr
  printf "\x1Bc"

  # clear scrollback buffer on macOS
  printf '\x1B[3J'
end
