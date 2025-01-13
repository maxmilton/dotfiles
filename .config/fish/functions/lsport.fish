function lsport
    echo -n
    ss -plantu | fzy --lines=max --query=$argv[1]
end
