function gg --description 'Switch git master🔁dev/next or checkout branch (+ create if not exists)'
  if test -z $argv[1]
    if test (git show-ref --hash --verify --head HEAD) != (git show-ref --hash refs/heads/master)
      git checkout master
    else if git show-ref --verify --quiet refs/heads/dev
      git checkout dev
    else if git show-ref --verify --quiet refs/heads/next
      git checkout next
    else
      echo 'Error: No local git branch named "dev" or "next" exist'
      return 1
    end
  else
    git checkout -b $argv 2> /dev/null; or git checkout $argv
  end
end
