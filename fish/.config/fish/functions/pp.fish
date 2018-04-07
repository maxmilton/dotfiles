function pp -d 'Get system package updates'
  yaourt -Syu --aur $argv
end
