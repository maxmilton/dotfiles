#
# FISH ALIASES
#
# Fish saves a compiled version of these commands after running once so they
# only need to be called one time initially or when updated. This is done
# automatically if using the dotfiles.sh script, so to reload this file run:
#
# $ ./dotfiles.sh -i fish
#

# Disable welcome message
set -U fish_greeting

# VIM = <3
set -U EDITOR vim
set -U VISUAL vim

# Node.js
set -U fish_user_paths $HOME/.config/yarn/global/node_modules/.bin $fish_user_paths
set -U NODE_PRESERVE_SYMLINKS 1

# Google Cloud SDK
set -U fish_user_paths $HOME/.google-cloud-sdk/bin $fish_user_paths

# fzf fisherman plugin
set -U FZF_LEGACY_KEYBINDINGS 0

# Misc
abbr --add C 'math' # calculator function
abbr --add get 'aria2c --dir ~/Downloads' # download via CLI
abbr --add ppp 'pp; pp-gce; pp-fish; dup; pp-yarn; pp-git' # run full system update
abbr --add p 'yaourt' # Arch Linux package manager

# System
abbr --add s 'sudo -i'
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'
abbr --add ..... 'cd ../../../..'
abbr --add ...... 'cd ../../../../..'
abbr --add ....... 'cd ../../../../../..'
abbr --add -- - 'cd --' # single dash will go back to previous dir
abbr --add cp 'cp -i'
abbr --add mv 'mv -i'
abbr --add l 'ls -lFA --group-directories-first'
abbr --add ll 'ls -lFA'
abbr --add lll 'ls -CFA'
abbr --add lh 'ls -lFAh --group-directories-first'
abbr --add find 'find -O3'
abbr --add ffind 'find -O3 . ! -path "node_modules" ! -path ".git" -type f -iname "*xx*"' # better to use CTRL+f (fzf)
abbr --add dux 'du -hs | sort -h'
abbr --add dus 'du --block-size=MiB --max-depth=1 | sort -n'
abbr --add 755 'find . -type d -exec chmod 755 {} \; and echo "Done!"'
abbr --add 700 'find . -type d -exec chmod 700 {} \; and echo "Done!"'
abbr --add 644 'find . -type f ! -name ".git" ! -name "*.sh" ! -executable -exec chmod 644 {} \; and echo "Done!"'
abbr --add 600 'find . -type f ! -name ".git" ! -name "*.sh" ! -executable -exec chmod 600 {} \; and echo "Done!"'

# Sysadmin
abbr --add gce 'while not gce-ssh; echo "retrying..."; sleep 3; end'
abbr --add scs 'sc status' # systemctl
abbr --add scr 'sc restart'
abbr --add getip 'curl -4 icanhazip.com'
abbr --add getip6 'curl -6 icanhazip.com'
abbr --add getptr 'curl -4 icanhazptr.com'
abbr --add t 'terraform'
# remove all broken symlinks in a dir
abbr --add lnrm 'find -L . -maxdepth 1 -type l -delete'

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
# run dev box with persistence
abbr --add alpine 'docker start -i alpine; or docker run -ti --name alpine alpine:edge sh; or docker exec -ti alpine'
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

# K8s
abbr --add k 'kubectl'
abbr --add kg 'kubectl get'
abbr --add kgp 'kubectl get pods -o wide'
abbr --add kgs 'kubectl get services -o wide'
abbr --add kgd 'kubectl get deployments -o wide'
abbr --add kd 'kubectl describe'
abbr --add kr 'kubectl rollout status deployments/'
abbr --add krs 'kubectl rollout status deployments/'
abbr --add krus 'kubectl rollout undo deployments/'
abbr --add ke 'kubectl exec'
abbr --add kp 'kubectl proxy'
abbr --add kpass 'k config view --minify'

# Development
abbr --add uu 'ncu; and yarn; and yarn upgrade'
abbr --add uuu 'ncu --upgradeAll; and yarn; and yarn upgrade'
abbr --add yb 'y build'
abbr --add yt 'y lint; and y test --coverage'
abbr --add yy 'clr; y'
abbr --add yyb 'clr; y build'
abbr --add yyt 'clr; y lint; and y test --coverage'
abbr --add yi 'yarn info'
abbr --add travis 'docker run -ti --rm -v $PWD:/project maxmilton/travis'
abbr --add ttl 'travis lint ./.travis.yml'
abbr --add gogo 'docker run --rm -v $PWD:/go/src/app -w /go/src/app golang:alpine go'

# Git
abbr --add g 'git'
abbr --add gs 'git status --short --branch --show-stash'
abbr --add gp 'git pull --prune'
# 1. Configure upstream remote - ref: https://help.github.com/articles/configuring-a-remote-for-a-fork/
# 2. Sync fork with upstream: run ggll - ref: https://help.github.com/articles/syncing-a-fork/
abbr --add gpp 'git fetch upstream; and git merge upstream/master master'
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
# review changes from last pull
abbr --add gpd "git log --reverse --no-merges --stat '@{1}..'"
abbr --add gc 'env GIT_EDITOR="vim +startinsert" git commit --verbose'
abbr --add gca 'env GIT_EDITOR="vim +startinsert" git commit --verbose --all'
abbr --add gg 'gchkout'
abbr --add gco 'git checkout' # better to use gg/gchkout function most of the time
abbr --add gb 'git branch'
abbr --add gm 'git merge'
abbr --add gt 'git tag'
# remove missing files
abbr --add grm 'git ls-files --deleted -z | xargs -0 git rm'
