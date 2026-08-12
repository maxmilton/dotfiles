#!/usr/bin/env fish

# List video files with resolution, codec, size, bitrate, and filename.
# Sort descending by pixel count, then bitrate, then file size.

set -l dir .
set -q argv[1]; and set dir $argv[1]

if not test -d "$dir"
    echo "Not a directory: $dir" >&2
    exit 1
end

for cmd in ffprobe sort numfmt column
    type -q $cmd; or begin
        echo "Missing command: $cmd" >&2
        exit 127
    end
end

for file in (path filter -f -- "$dir"/* "$dir"/.*)
    set -l codec_name
    set -l width
    set -l height
    set -l size
    set -l bit_rate 0

    for line in (
        ffprobe -v error \
            -select_streams v:0 \
            -show_entries stream=codec_name,width,height:format=size,bit_rate \
            -of default=nw=1 \
            "$file" 2>/dev/null
    )
        set -l pair (string split -m1 = -- $line)
        set $pair[1] $pair[2]
    end

    string match -qr '^\d+$' -- "$width"; or continue
    string match -qr '^\d+$' -- "$height"; or continue
    string match -qr '^\d+$' -- "$size"; or continue
    string match -qr '^\d+$' -- "$bit_rate"; or set bit_rate 0

    printf '%d\t%d\t%d\t%sx%s\t%s\t%s\0' \
        (math "$width * $height") \
        $bit_rate \
        $size \
        $width \
        $height \
        $codec_name \
        (path basename "$file")
end |
    sort -z -t \t -k1,1nr -k2,2nr -k3,3nr |
    while read -z -d \t pixels bit_rate size resolution codec file
        set i (math "$i + 1")

        printf '%d\t%s\t%s\t%s\t%s\t%s\n' \
            $i \
            $resolution \
            $codec \
            (numfmt --to=iec-i --suffix=B --format='%.1f' $size) \
            (numfmt --to=si --suffix=b/s --format='%.2f' $bit_rate) \
            "$file"
    end |
    column \
        --table \
        --separator \t \
        --output-width 0 \
        --table-columns '#,RESOLUTION,CODEC,SIZE,BITRATE,FILE' \
        --table-right '#,SIZE,BITRATE'
