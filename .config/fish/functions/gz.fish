function gz
  cat $argv 2>/dev/null | read -lz input
  set -ql input; or set -l input $argv[1]

  # original file
  set -l orig (echo "$input" | wc -c)
  set -l sizek1 (math -s2 "$orig / 1000")

  # zstd -5
  set -l start2 (date '+%s%3N')
  set -l size2 (echo "$input" | zstd -5 -c | wc -c)
  set -l stop2 (date '+%s%3N')
  set -l duration2 (math "$stop2 - $start2")
  set -l sizek2 (math -s2 "$size2 / 1000")
  set -l percent2 (math -s2 "($size2 / $orig) * 100")

  # gzip -5
  set -l start3 (date '+%s%3N')
  set -l size3 (echo "$input" | gzip -cf -5 | wc -c)
  set -l stop3 (date '+%s%3N')
  set -l duration3 (math "$stop3 - $start3")
  set -l sizek3 (math -s2 "$size3 / 1000")
  set -l percent3 (math -s2 "($size3 / $orig) * 100")

  # gzip -9
  set -l start4 (date '+%s%3N')
  set -l size4 (echo "$input" | gzip -cf -9 | wc -c)
  set -l stop4 (date '+%s%3N')
  set -l duration4 (math "$stop4 - $start4")
  set -l sizek4 (math -s2 "$size4 / 1000")
  set -l percent4 (math -s2 "($size4 / $orig) * 100")

  # brotli -5
  set -l start5 (date '+%s%3N')
  set -l size5 (echo "$input" | brotli -cf -5 | wc -c)
  set -l stop5 (date '+%s%3N')
  set -l duration5 (math "$stop5 - $start5")
  set -l sizek5 (math -s2 "$size5 / 1000")
  set -l percent5 (math -s2 "($size5 / $orig) * 100")

  # brotli -Z (best; same as -11)
  set -l start6 (date '+%s%3N')
  set -l size6 (echo "$input" | brotli -cf -Z | wc -c)
  set -l stop6 (date '+%s%3N')
  set -l duration6 (math "$stop6 - $start6")
  set -l sizek6 (math -s2 "$size6 / 1000")
  set -l percent6 (math -s2 "($size6 / $orig) * 100")

  # colours
  set -l normal (set_color normal)
  set -l grey (set_color brblack)
  set -l yellow (set_color bryellow)
  set -l red (set_color brred)

  printf "%soriginal,%i,%g,%g,\n%szstd -5,%i,%g,%g,%i ms\n%sgzip -5,%i,%g,%g,%i ms\n%sgzip -9,%i,%g,%g,%i ms\n%sbrotli -5,%i,%g,%g,%i ms\n%sbrotli -Z,%i,%g,%g,%i ms\n" \
    $red $orig $sizek1 100 \
    $red $size2 $sizek2 $percent2 $duration2 \
    $red $size3 $sizek3 $percent3 $duration3 \
    $red $size4 $sizek4 $percent4 $duration4 \
    $red $size5 $sizek5 $percent5 $duration5 \
    $red $size6 $sizek6 $percent6 $duration6 \
    | column --table --table-columns "$yellow"SOURCE,"$yellow"B,"$yellow"KB,"$yellow"%,"$yellow"TIME --output-separator " $grey│$normal " --separator ','
end
