function gz --description 'Compare gzip\'d sizes of a file'
  cat $argv ^/dev/null | tr -d '\n' | read -l input
  set -ql input; or set -l input $argv[1]

  # colours
  set -l normal (set_color normal)
  set -l grey (set_color brblack)
  set -l yellow (set_color bryellow)
  set -l red (set_color brred)

  # table parts
  set -l divY "$grey│$yellow"
  set -l divN "$grey│$normal"

  # original file
  set -l orig (echo "$input" | wc -c)
  set -l sizek1 (math -s2 "$orig / 1024")

  # gzip -6
  set -l start2 (date '+%s%3N')
  set -l size2 (echo "$input" | gzip -cf -6 | wc -c)
  set -l stop2 (date '+%s%3N')
  set -l duration2 (math "$stop2 - $start2")
  set -l sizek2 (math -s2 "$size2 / 1024")
  # set -l percent2 (math -s2 "($size2 / $orig) * 100")
  set -l percent2 (math -s2 "($size2 / $orig) * 100")

  # gzip -9
  set -l start3 (date '+%s%3N')
  set -l size3 (echo "$input" | gzip -cf -9 | wc -c)
  set -l stop3 (date '+%s%3N')
  set -l duration3 (math "$stop3 - $start3")
  set -l sizek3 (math -s2 "$size3 / 1024")
  set -l percent3 (math -s2 "($size3 / $orig) * 100")

  # brotli -9
  set -l start4 (date '+%s%3N')
  set -l size4 (echo "$input" | brotli -cf -9 | wc -c)
  set -l stop4 (date '+%s%3N')
  set -l duration4 (math "$stop4 - $start4")
  set -l sizek4 (math -s2 "$size4 / 1024")
  set -l percent4 (math -s2 "($size4 / $orig) * 100")

  echo ""
  echo -e $yellow "source    $divY B     $divY KB    $divY %   $divY time"
  echo -e $grey "──────────┼───────┼───────┼─────┼──────"
  echo -e $red "original " $divN $orig $divN $sizek1 $divN 100
  echo -e $red "gzip -6   $divN $size2  $divN $sizek2  $divN $percent2 $divN $duration2 ms"
  echo -e $red "gzip -9   $divN $size3  $divN $sizek3  $divN $percent3 $divN $duration3 ms"
  echo -e $red "brotli -9 $divN $size4  $divN $sizek4  $divN $percent4 $divN $duration4 ms"

  # reset colour
  echo -en $normal
end
