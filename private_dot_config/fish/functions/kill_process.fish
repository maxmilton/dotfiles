# TODO: Add multi-select once availiable in fzy -- https://github.com/jhawthorn/fzy/pull/124

function kill_process --description 'Kill processes'
  set -l __kp__pid ''

  if contains -- '--tcp' $argv
    set __kp__pid (lsof -Pwni tcp | sed 1d | fzy --lines 20 | awk '{print $2}')
  else
    set __kp__pid (ps -ef | sed 1d | fzy --lines 20 | awk '{print $2}')
  end

  set -l __kp__kc $argv[1]

  if test "x$__kp__pid" != "x"
    if test "x$argv[1]" != "x"
      echo $__kp__pid | xargs kill $argv[1]
    else
      echo $__kp__pid | xargs kill -9
    end

    kill_process
  end
end
