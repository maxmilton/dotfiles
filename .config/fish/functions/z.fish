# Generated with: jump shell fish --bind=z

function __jump_add --on-variable PWD
  status --is-command-substitution; and return
  jump chdir
end

function __jump_hint
  set -l term (string replace -r '^z ' '' -- (commandline -cp))
  jump hint "$term"
end

function z
  set -l dir (jump cd "$argv")
  test -d "$dir"; and cd "$dir"
end

complete --command z --exclusive --arguments '(__jump_hint)'
