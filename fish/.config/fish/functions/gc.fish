function gc -d 'git commit'
  env GIT_EDITOR="vim +startinsert" git commit --verbose $argv
end
