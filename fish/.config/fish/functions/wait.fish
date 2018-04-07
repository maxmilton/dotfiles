# wait
#
# Wait for all background jobs to finish. For use in other functions.
#
# REF:
#   https://github.com/jorgebucaran/fish-shell-cookbook#how-to-synchronize-two-or-more-background-tasks-in-fish
#
# USAGE EXAMPLE:
#   function wait
#     while true
#       set -l has_jobs
#       set -l all_jobs (get_jobs)
#       or break

#       for j in $argv
#         if contains -- $j $all_jobs
#           set -e has_jobs
#           break
#         end
#       end

#       if set -q has_jobs
#         break
#       end
#     end
#   end
#

function wait -d 'Wait for all background jobs to finish'
  while true
    set -l has_jobs
    set -l all_jobs (get_jobs)
    or break

    for j in $argv
      if contains -- $j $all_jobs
        set -e has_jobs
        break
      end
    end

    if set -q has_jobs
      break
    end
  end
end
