#
# FISH GLOBALS & ALIASES
#
# Fish saves a compiled version of these commands after running once so they
# only need to be called one time initially or when updated. This is done
# automatically if using the dotfiles.sh script, so to reload this file run:
#
# $ ./dotfiles.sh -i fish
#

# update completions
fish_update_completions

# Erase all previous fish abbreviations
set -e fish_user_abbreviations

# Disable welcome message
set -U fish_greeting

# VIM = <3
set -Ux EDITOR vim
set -Ux VISUAL vim

# Node.js
set node_bin_path $HOME/.config/yarn/global/node_modules/.bin
if test -d $node_bin_path
  set -U fish_user_paths $node_bin_path $fish_user_paths
  set -U NODE_PRESERVE_SYMLINKS 1
end

# Golang
set go_bin_path $HOME/go/bin
if test -d $go_bin_path
  set -U fish_user_paths $go_bin_path $fish_user_paths
end

# Google Cloud SDK
set gcloud_bin_path $HOME/.google-cloud-sdk/bin
if test -d $gcloud_bin_path
  set -U fish_user_paths $gcloud_bin_path $fish_user_paths
end

# fisherman plugins
set -U FZF_LEGACY_KEYBINDINGS 0
set -U FZF_COMPLETE 0

# Misc
abbr --add C 'math ' # CLI calculator
abbr --add get 'aria2c --dir ~/Downloads' # download via CLI
abbr --add ppp 'up_system; up_fish; up_yarn; up_gce; up_docker; up_git; up_hosts; up_flatpak' # run full system update
abbr --add p 'yaourt' # Arch Linux package manager
abbr --add f 'flatpak' # generic app image manager
abbr --add dot 'chezmoi' # dotfiles manager

# System
abbr --add s 'sudo -i'
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'
abbr --add ..... 'cd ../../../..'
abbr --add ...... 'cd ../../../../..'
abbr --add ....... 'cd ../../../../../..'
abbr --add -- - 'cd --' # single dash to go back to previous dir
abbr --add cp 'cp -i'
abbr --add mv 'mv -i'
abbr --add l 'ls -lFA --group-directories-first'
abbr --add ll 'ls -lFA'
abbr --add lll 'ls -CFA'
abbr --add lh 'ls -lFAh --group-directories-first'
# list dirs (not files) recursively, excluding .git and node_modules
abbr --add ld 'find -O3 . -type d \( -name .git -o -name node_modules \) -prune -o -type d -print'
abbr --add find 'find -O3'
abbr --add dux 'du -hs | sort -h'
abbr --add dus 'du --block-size=MiB --max-depth=1 | sort -n'
abbr --add 755 'find -O3 . -type d -name .git -prune -o -type d -exec chmod 755 {} \;'
abbr --add 700 'find -O3 . -type d -name .git -prune -o -type d -exec chmod 700 {} \;'
abbr --add 644 'find -O3 . -type d -name .git -prune -o -type f ! -name "*.sh" ! -executable -exec chmod 644 {} \;'
abbr --add 600 'find -O3 . -type d -name .git -prune -o -type f ! -name "*.sh" ! -executable -exec chmod 600 {} \;'

# Sysadmin
abbr --add gce 'while not gce-ssh; echo "retrying..."; sleep 3; end'
abbr --add scs 'sc status' # systemctl
abbr --add scr 'sc restart'
abbr --add getip 'curl -4 icanhazip.com'
abbr --add getip6 'curl -6 icanhazip.com'
abbr --add getptr 'curl -4 icanhazptr.com'
abbr --add t 'terraform'
# remove all broken symlinks in dir
# abbr --add rmln 'find -L . -maxdepth 1 -type l -delete'
abbr --add rmln 'find -L . -name . -o -type d -prune -o -type l -exec rm -rf {} \;'
# remove all node_modules dirs recursively
abbr --add rmnm 'find -O3 . -type d -name .git -prune -o -type d -name node_modules -prune -exec rm -rf {} \;'
# remove all yarn-error.log files recursively
abbr --add rmye 'find -O3 . -type d \( -name .git -o -name node_modules \) -prune -o -type f -name yarn-error.log -exec rm {} \;'
# list open ports
abbr --add lsport 'sudo ss -plant'
# list open ports on macOS
abbr --add netls 'sudo lsof -iTCP -sTCP:LISTEN -n -P'
# debug bash script
abbr --add bashx 'env PS4="\$(if [[ \$? == 0 ]]; then echo \"\033[0;33mEXIT: \$? ✔\"; else echo \"\033[1;91mEXIT: \$? ❌\033[0;33m\"; fi)\n\nSTACK:\n\${BASH_SOURCE[0]}:\${LINENO}\n\${BASH_SOURCE[*]:1}\n\033[0m" bash -x'

# Net tools
abbr --add nt 'docker run -ti --rm --network=host --volume="$PWD":/data local/net-tools'
# abbr --add curl 'docker run -ti --rm --network=host --volume="$PWD":/data local/net-tools curl'
abbr --add drill 'docker run -ti --rm local/net-tools drill'
abbr --add htop 'docker run -ti --rm --pid=host --volume="$HOME"/.config/htop/htoprc:/root/.config/htop/htoprc local/net-tools htop'
abbr --add iperf 'docker run -ti --rm --network=host local/net-tools iperf'
abbr --add jq 'docker run -ti --rm --volume="$PWD":/data local/net-tools jq'
abbr --add mtr 'docker run -ti --rm local/net-tools mtr'
abbr --add nmap 'docker run -ti --rm --network=host --volume="$PWD":/data local/net-tools nmap'
abbr --add ncat 'docker run -ti --rm --network=host --volume="$PWD":/data local/net-tools ncat'
abbr --add nping 'docker run -ti --rm --network=host local/net-tools nping'
# abbr --add ssh 'docker run -ti --rm --network=host --volume="$HOME"/.ssh:/root/.ssh:ro --volume="$PWD":/data local/net-tools ssh'
# abbr --add sftp 'docker run -ti --rm --network=host --volume="$HOME"/.ssh:/root/.ssh:ro --volume="$PWD":/data local/net-tools sftp'
# abbr --add scp 'docker run -ti --rm --network=host --volume="$HOME"/.ssh:/root/.ssh:ro --volume="$PWD":/data local/net-tools scp'
abbr --add tcpdump 'docker run -ti --rm --network=host --volume="$PWD":/data local/net-tools tcpdump'
abbr --add whois 'docker run -ti --rm local/net-tools whois'

# Docker
abbr --add d 'docker'
abbr --add di 'docker images'
# show running containers
abbr --add dps 'docker ps'
# show all containers including stopped
abbr --add dpa 'docker ps -a'
# monitor all containers
abbr --add ds 'docker stats (docker ps -q)'
# run interactively then remove
abbr --add dr 'docker run -ti --rm'
abbr --add drr 'docker run -ti --rm alpine:edge sh'
# pull image from the hub.docker.com
abbr --add dp 'docker pull'
# get latest container ID
abbr --add dl 'docker ps -l -q'
# get container IP
abbr --add dip "docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
# remove orphaned volumes
abbr --add drmv 'docker volume ls -qf dangling=true | xargs -r docker volume rm'
abbr --add dc 'docker-compose'
abbr --add dcu 'docker-compose up'
abbr --add dcd 'docker-compose down'
abbr --add dcr 'docker-compose down; and docker-compose up'
# get a shell in the host via docker
abbr --add dnse 'docker run -it --rm --privileged --pid=host justincormack/nsenter1'

# K8s
abbr --add k 'kubectl'
abbr --add ka 'kubectl apply --dry-run -f'
abbr --add kx 'kubectl delete --dry-run -f'
abbr --add kg 'kubectl get'
abbr --add kgp 'kubectl get pods -o wide'
abbr --add kgs 'kubectl get services -o wide'
abbr --add kgd 'kubectl get deployments -o wide'
abbr --add kd 'kubectl describe'
abbr --add kdn 'kubectl describe nodes'
abbr --add kr 'kubectl rollout status deployments/'
abbr --add krs 'kubectl rollout status deployments/'
abbr --add krus 'kubectl rollout undo deployments/'
abbr --add ke 'kubectl exec'
abbr --add kp 'kubectl proxy'
abbr --add kpass 'kubectl -n kube-system describe secret (kubectl -n kube-system get secret | grep admin-user | awk \'{print $1}\')'
abbr --add h 'helm'
abbr --add hl 'helm ls --tls'
abbr --add hf 'helm fetch'
abbr --add hi 'helm install'
abbr --add i 'istioctl'
abbr --add ii 'istioctl kube-inject -f'

# Development
abbr --add uu 'yarn upgrade-interactive --latest'
abbr --add yy 'clr; y'
abbr --add yb 'yarn run build'
abbr --add yyb 'clr; yarn run build'
abbr --add yt 'yarn run lint; and yarn run test-ci'
abbr --add yyt 'clr; yarn run lint; and yarn run test-ci'
abbr --add ytt 'yarn run lint; and env yarn jest --coverage'
abbr --add yytt 'clr; yarn run lint; and env yarn jest --coverage'
abbr --add yr 'clr; yarn run _run'
abbr --add ys 'yarn run serve'
abbr --add yi 'yarn info'
abbr --add tl 'travis lint ./.travis.yml'

# Git
abbr --add g 'git'
abbr --add gs 'git status --short --branch --show-stash'
abbr --add gp 'git pull --prune'
# 1. Configure upstream remote - ref: https://help.github.com/articles/configuring-a-remote-for-a-fork/
# 2. Sync fork with upstream: run gpp - ref: https://help.github.com/articles/syncing-a-fork/
abbr --add gpp 'git fetch upstream; and git merge upstream/master master; and git push origin master'
# flat log (great for quick reference)
abbr --add gl "git log --format='%C(auto)%h %s %Cgreen%cr %Cblue%an%C(auto)%d%Creset' --no-merges"
# simple log
abbr --add glo 'git log --decorate --oneline --graph'
# full log
abbr --add gloo 'git log --decorate --graph --abbrev-commit --date=relative'
# fancy log
abbr --add glooo "git log --graph --pretty=format:'%C(auto)%h %Cgreen%cr%C(auto)%d %s %Cblue%an%Creset' --abbrev-commit"
abbr --add ga 'git add'
abbr --add gd 'git diff'
abbr --add gdd 'git diff --staged'
# see changes in origin
abbr --add gpd 'git diff master..origin/master'
# see changes in upstream
abbr --add gpd 'git fetch upstream; git diff master..upstream/master'
# review changes from last pull
abbr --add gpd "git log --reverse --no-merges --stat '@{1}..'"
# see unpushed commits
abbr --add gout 'git log --stat "@{u}"..'
# see unpushed commits on all branches
abbr --add gouta 'git log --stat --decorate --branches --not --remotes'
# see unpulled commit
abbr --add gin 'git log --stat .."@{u}"'
abbr --add gc 'env GIT_EDITOR="vim +startinsert" git commit --verbose'
abbr --add gca 'env GIT_EDITOR="vim +startinsert" git commit --verbose --all'
abbr --add gg 'gchkout'
abbr --add gco 'git checkout' # better to use gg/gchkout function most of the time
abbr --add gb 'git branch'
abbr --add gm 'git merge'
abbr --add gt 'git tag'
# remove missing files
abbr --add grm 'git ls-files --deleted -z | xargs -0 git rm'
