function kill_process --description 'Kill processes'
  set -l proc_pid ''

  if contains -- '--tcp' $argv
    set proc_pid (lsof -Pwni tcp | sed 1d | fzy --lines 20 | awk '{print $2}')
  else
    set proc_pid (ps -ef | sed 1d | fzy --lines 20 | awk '{print $2}')
  end

  if test "x$proc_pid" != "x"
    if test "x$argv[1]" != "x"
      echo $proc_pid | xargs kill $argv[1]
    else
      echo $proc_pid | xargs kill -9
    end

    kill_process
  end
end
