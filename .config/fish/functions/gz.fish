function gz
    set -l total_start (date '+%s%5N')

    cat $argv 2>/dev/null | read -lz input
    set -ql input; or set -l input $argv[1]

    # original file
    set -l orig (echo "$input" | wc -c)
    set -l sizek1 (math -s2 "$orig / 1000")

    # lz4 -1
    set -l start2 (date '+%s%5N')
    set -l size2 (echo "$input" | lz4 -1 -c | wc -c)
    set -l stop2 (date '+%s%5N')
    set -l duration2 (math "($stop2 - $start2) / 100")
    set -l sizek2 (math -s2 "$size2 / 1000")
    set -l percent2 (math -s2 "($size2 / $orig) * 100")

    # lz4 --best (same as -12)
    set -l start3 (date '+%s%5N')
    set -l size3 (echo "$input" | lz4 --best -c | wc -c)
    set -l stop3 (date '+%s%5N')
    set -l duration3 (math "($stop3 - $start3) / 100")
    set -l sizek3 (math -s2 "$size3 / 1000")
    set -l percent3 (math -s2 "($size3 / $orig) * 100")

    # zstd -5
    set -l start4 (date '+%s%5N')
    set -l size4 (echo "$input" | zstd -5 -c | wc -c)
    set -l stop4 (date '+%s%5N')
    set -l duration4 (math "($stop4 - $start4) / 100")
    set -l sizek4 (math -s2 "$size4 / 1000")
    set -l percent4 (math -s2 "($size4 / $orig) * 100")

    # zstd -19
    set -l start5 (date '+%s%5N')
    set -l size5 (echo "$input" | zstd -19 -c | wc -c)
    set -l stop5 (date '+%s%5N')
    set -l duration5 (math "($stop5 - $start5) / 100")
    set -l sizek5 (math -s2 "$size5 / 1000")
    set -l percent5 (math -s2 "($size5 / $orig) * 100")

    # gzip -5
    set -l start6 (date '+%s%5N')
    set -l size6 (echo "$input" | gzip -cf -5 | wc -c)
    set -l stop6 (date '+%s%5N')
    set -l duration6 (math "($stop6 - $start6) / 100")
    set -l sizek6 (math -s2 "$size6 / 1000")
    set -l percent6 (math -s2 "($size6 / $orig) * 100")

    # gzip -9
    set -l start7 (date '+%s%5N')
    set -l size7 (echo "$input" | gzip -cf -9 | wc -c)
    set -l stop7 (date '+%s%5N')
    set -l duration7 (math "($stop7 - $start7) / 100")
    set -l sizek7 (math -s2 "$size7 / 1000")
    set -l percent7 (math -s2 "($size7 / $orig) * 100")

    # brotli -5
    set -l start8 (date '+%s%5N')
    set -l size8 (echo "$input" | brotli -cf -5 | wc -c)
    set -l stop8 (date '+%s%5N')
    set -l duration8 (math "($stop8 - $start8) / 100")
    set -l sizek8 (math -s2 "$size8 / 1000")
    set -l percent8 (math -s2 "($size8 / $orig) * 100")

    # brotli -Z (best; same as -11)
    set -l start9 (date '+%s%5N')
    set -l size9 (echo "$input" | brotli -cf -Z | wc -c)
    set -l stop9 (date '+%s%5N')
    set -l duration9 (math "($stop9 - $start9) / 100")
    set -l sizek9 (math -s2 "$size9 / 1000")
    set -l percent9 (math -s2 "($size9 / $orig) * 100")

    set -l normal (set_color normal)
    set -l grey (set_color brblack)
    set -l yellow (set_color bryellow)
    set -l red (set_color brred)

    printf "%soriginal,%i,%g,%g,\n%slz4 -1,%i,%g,%g,%.2f ms\n\n%slz4 --best,%i,%g,%g,%.2f ms\n%szstd -5,%i,%g,%g,%.2f ms\n%szstd -19,%i,%g,%g,%.2f ms\n%sgzip -5,%i,%g,%g,%.2f ms\n%sgzip -9,%i,%g,%g,%.2f ms\n%sbrotli -5,%i,%g,%g,%.2f ms\n%sbrotli -Z,%i,%g,%g,%.2f ms\n" \
        $red $orig $sizek1 100 \
        $red $size2 $sizek2 $percent2 $duration2 \
        $red $size3 $sizek3 $percent3 $duration3 \
        $red $size4 $sizek4 $percent4 $duration4 \
        $red $size5 $sizek5 $percent5 $duration5 \
        $red $size6 $sizek6 $percent6 $duration6 \
        $red $size7 $sizek7 $percent7 $duration7 \
        $red $size8 $sizek8 $percent8 $duration8 \
        $red $size9 $sizek9 $percent9 $duration9 \
        | column --table --table-columns "$yellow"SOURCE,"$yellow"B,"$yellow"KB,"$yellow"%,"$yellow"TIME --output-separator " $grey│$normal " --separator ','

    set -l total_end (date '+%s%5N')
    set -l total_duration (math "($total_end - $total_start) / 100")
    echo "Total: $total_duration ms"
end
