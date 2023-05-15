function gg
  git checkout (git branch --all --format "%(refname:lstrip=2)" | fzy --lines max --query=$argv[1])
end
