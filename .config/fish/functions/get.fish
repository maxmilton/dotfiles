function get
    /usr/bin/aria2c \
        --dir="$HOME/Downloads" \
        --file-allocation=falloc \
        --max-connection-per-server=16 \
        --continue \
        $argv
end
