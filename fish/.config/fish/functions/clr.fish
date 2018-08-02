function clr -d 'Clear console buffer'
  printf "\x1Bc"

  # clear scrollback buffer on macOS
  printf '\x1B[3J'
end
