function bashx --description 'Debug bash script'
    env PS4="\$(if [[ \$? == 0 ]]; then echo \"\033[0;33mEXIT: \$? ✔\"; else echo \"\033[1;91mEXIT: \$? ❌\033[0;33m\"; fi)\n\nSTACK:\n\${BASH_SOURCE[0]}:\${LINENO}\n\${BASH_SOURCE[*]:1}\n\033[0m" bash -x $argv
end
