function yit -d 'Get yarn package dist-tags info (without extra data)'
  yarn info $argv[1] --json | jq '.data | {name: .name, "dist-tags": .["dist-tags"]}'
end
