function kill_process --description 'Kill processes'
  set -l __kp_pid ''

  if contains -- '--tcp' $argv
    set __kp_pid (lsof -Pwni tcp | sed 1d | fzy --lines 20 | awk '{print $2}')
  else
    set __kp_pid (ps -ef | sed 1d | fzy --lines 20 | awk '{print $2}')
  end

  set -l __kp_kc $argv[1]

  if test "x$__kp_pid" != "x"
    if test "x$argv[1]" != "x"
      echo $__kp_pid | xargs kill $argv[1]
    else
      echo $__kp_pid | xargs kill -9
    end

    kill_process
  end
end
