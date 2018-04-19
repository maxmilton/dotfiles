function travis -d "Run travis commands"
  docker run -ti --rm -v $PWD:/project maxmilton/travis $argv
end
