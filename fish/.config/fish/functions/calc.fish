function calc -d 'Command line calculator'
  echo "$argv" | tr -d \"-\', | bc -l
end
