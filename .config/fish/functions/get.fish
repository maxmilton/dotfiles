function get
  aria2c \
    --dir ~/Downloads \
    --file-allocation=falloc \
    --max-connection-per-server=16 \
    --continue \
    $argv
end
