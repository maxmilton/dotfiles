function gz -d 'Compare gzip\'d sizes of a file'
  echo -e "\e[93moriginal (bytes / kilobytes / percent): \e[0m"
  set orig (wc -c < "$argv[1]")
  set sizek (calc $orig / 1024 | printf "%0.2f\n")
  echo "$orig B / $sizek K"

  echo -e "\e[91mgzip -1: \e[0m"
  set size (gzip -c -1 "$argv[1]" | wc -c)
  set sizek (calc $size / 1024 | printf "%0.2f\n")
  set percent (calc "\($size / $orig\) * 100" | printf "%0.2f\n")
  echo "$size B / $sizek K / $percent %"

  echo -e "\e[91mgzip -5: \e[0m"
  set size (gzip -c -5 "$argv[1]" | wc -c)
  set sizek (calc $size / 1024 | printf "%0.2f\n")
  set percent (calc "\($size / $orig\) * 100" | printf "%0.2f\n")
  echo "$size B / $sizek K / $percent %"

  echo -e "\e[91mgzip -6: \e[0m"
  set size (gzip -c -6 "$argv[1]" | wc -c)
  set sizek (calc $size / 1024 | printf "%0.2f\n")
  set percent (calc "\($size / $orig\) * 100" | printf "%0.2f\n")
  echo "$size B / $sizek K / $percent %"

  echo -e "\e[91mgzip -9: \e[0m"
  set size (gzip -c -9 "$argv[1]" | wc -c)
  set sizek (calc $size / 1024 | printf "%0.2f\n")
  set percent (calc "\($size / $orig\) * 100" | printf "%0.2f\n")
  echo "$size B / $sizek K / $percent %"
end
