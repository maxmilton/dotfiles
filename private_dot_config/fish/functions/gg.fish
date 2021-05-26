function gchkout --description 'Switch master🔁dev or checkout branch (create if not exists)'
  if test -z $argv[1]
    if test (git symbolic-ref --short HEAD) = "master"
      git checkout dev
    else
      git checkout master
    end
  else
    git checkout -b $argv 2> /dev/null; or git checkout $argv
  end
end
