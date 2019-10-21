function git_info --description 'Print information about a git repo'
  set -l dir $argv[1]
  set -l reset (set_color normal)
  echo -s (set_color --bold cyan) '📂 ' $dir $reset
  echo -s (set_color yellow) '🔖 ' (git -C $dir rev-parse --abbrev-ref HEAD) $reset
end
