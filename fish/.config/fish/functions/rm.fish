function rm -d 'Move files into trash'
  if test (uname -s) != 'Darwin'
    # Linux
    gio trash $argv
  else
    # macOS
    rmtrash $argv
  end
end
