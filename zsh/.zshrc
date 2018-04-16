# Oh My ZSH
#export ZSH=$HOME/.oh-my-zsh
#export ZSH_THEME="mm" # Based on af-magic
#export DISABLE_AUTO_UPDATE="true"
#export COMPLETION_WAITING_DOTS="true"
#export DISABLE_UNTRACKED_FILES_DIRTY="true"
#export plugins=(docker git terraform z)
#source "$ZSH"/oh-my-zsh.sh

# Pure ZSH
# https://github.com/sindresorhus/pure#install
autoload -U promptinit; promptinit
prompt pure

# Z jumper
#source $HOME/Development/0__github_projects/z/z.sh

# VIM = <3
export EDITOR="vim"
export VISUAL="vim"

# Less syntax highlighting (needs boostlibs so not worth it on minimal systems)
#export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
#export LESS=' -R '

# Spell check commands
setopt CORRECT
#setopt nocorrect

# Do fuzzy matching
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

# Inline alias expansion
globalias() {
  if [[ $LBUFFER =~ [a-zA-Z0-9]+$ ]]; then
    zle _expand_alias
    zle expand-word
  fi
  zle self-insert
}
zle -N globalias
bindkey " " globalias
bindkey "^ " magic-space           # control-space to bypass completion
bindkey -M isearch " " magic-space # normal space during searches

# Make new terminals adopt current directory
source /etc/profile.d/vte.sh

# Command line calculator
calc () { echo "$*" | tr -d \"-\', | bc -l; }
alias C='noglob calc'

# Compare gzip'd sizes of a file
gz() {
  echo -e "\e[93moriginal (bytes / kilobytes / percent): \e[0m"
  orig=$(wc -c < "$1")
  sizek=$(printf "%0.2f\n" $(calc $orig / 1024))
  echo "$orig B / $sizek K"

  echo -e "\e[91mgzip -1: \e[0m"
  size=$(gzip -c -1 "$1" | wc -c)
  sizek=$(printf "%0.2f\n" $(calc $size / 1024))
  percent=$(printf "%0.2f\n" $(calc "($size / $orig) * 100"))
  echo "$size B / $sizek K / $percent %"

  echo -e "\e[91mgzip -5: \e[0m"
  size=$(gzip -c -5 "$1" | wc -c)
  sizek=$(printf "%0.2f\n" $(calc $size / 1024))
  percent=$(printf "%0.2f\n" $(calc "($size / $orig) * 100"))
  echo "$size B / $sizek K / $percent %"

  echo -e "\e[91mgzip -6: \e[0m"
  size=$(gzip -c -6 "$1" | wc -c)
  sizek=$(printf "%0.2f\n" $(calc $size / 1024))
  percent=$(printf "%0.2f\n" $(calc "($size / $orig) * 100"))
  echo "$size B / $sizek K / $percent %"

  echo -e "\e[91mgzip -9: \e[0m"
  size=$(gzip -c -9 "$1" | wc -c)
  sizek=$(printf "%0.2f\n" $(calc $size / 1024))
  percent=$(printf "%0.2f\n" $(calc "($size / $orig) * 100"))
  echo "$size B / $sizek K / $percent %"
}

# Aliases: System
alias s='sudo -i'
alias rm='gio trash'
alias cp='cp -i'
alias mv='mv -i'
alias l='ls --color -aCFhlX --group-directories-first'
alias lsd='ls -lad */ .*/'
alias find='find -O3 . ! -path "node_modules" ! -path ".git" -type f -iname "*xx*"'
alias dux='du -hs | sort -h'
alias dus='du --block-size=MiB --max-depth=1 | sort -n'
alias clr='printf "\ec"'
alias 775='find . -type d -exec chmod 775 {} \; && echo "Done!"'
alias 755='find . -type d -exec chmod 755 {} \; && echo "Done!"'
alias 700='find . -type d -exec chmod 700 {} \; && echo "Done!"'
alias 664='find . -type f -not -name ".git" -not -name "*.sh" -not -executable -exec chmod 664 {} \; && echo "Done!"'
alias 644='find . -type f -not -name ".git" -not -name "*.sh" -not -executable -exec chmod 644 {} \; && echo "Done!"'
alias 600='find . -type f -not -name ".git" -not -name "*.sh" -not -executable -exec chmod 600 {} \; && echo "Done!"'
# alias ccze="ccze -A"
# alias t='tmux'
# alias ta='tmux attach'

# Aliases: Arch Linux
if [ $UID -ne 0 ]; then
 alias pacman='sudo pacman'
fi
alias p='yaourt'
alias pp='yaourt -Syu'

# Aliases: Fedora
#if [ $UID -ne 0 ]; then
#  alias dnf='sudo dnf'
#fi
#alias pp='dnf update --refresh'

# Aliases: Ubuntu
#if [ $UID -ne 0 ]; then
#  alias apt='sudo apt'
#  alias snap='sudo snap'
#fi
#alias pp='apt update && apt upgrade'

# Aliases: Systemctl
alias sc='systemctl'
alias jc='journalctl'
alias scs='systemctl status'
alias scr='systemctl restart'
# Use sudo if not root
if [ $UID -ne 0 ]; then
  alias sc='sudo systemctl'
  alias jc='sudo journalctl'
  alias scs='sudo systemctl status'
  alias scr='sudo systemctl restart'
fi

# Aliases: Development
alias c='/home/max/Development/LABS/docker-chromium/launch.sh'
alias b='/home/max/Development/LABS/docker-vlc/launch.sh'
# alias coco='sudo dnf install -y "$HOME"/Downloads/(code|atom)*.rpm && rm "$HOME"/Downloads/(code|atom)*.rpm' # install new VS Code & Atom packages
alias coco='sudo apt install -y "$HOME"/Downloads/(code|atom)*.deb && rm "$HOME"/Downloads/(code|atom)*.deb' # install new VS Code & Atom packages
alias sss='serve -n -o -l -s' # launch local http server
alias uu='ncu && yarn && yarn upgrade'
alias uuu='ncu --upgradeAll && yarn && yarn upgrade'
y() { if [ -z "$1" ]; then yarn run dev; else yarn run "$1"; fi }
alias yb='y build'
alias yt='y lint && y test --coverage'
alias yy='clr; y'
alias yyb='clr; y build'
alias yyt='clr; y lint && y test --coverage'
alias yi='yarn info'
alias travis='docker run -ti --rm -v $(pwd):/project maxmilton/travis'
alias ttl='travis lint ./.travis.yml'
alias gogo='docker run --rm -v $(pwd):/go/src/app:z -w /go/src/app golang:alpine go'

# generate JSDoc and open result in browser
mkdoc() {(
  DIR=$(mktemp -d)
  setopt extendedglob
  jsdoc -c "$HOME"/.jsdocrc.js -d "$DIR" $@ (package.json|README.md) (^(node_modules|dist)/)#*.(js|vue|marko)(.)
  xdg-open "file://$DIR/$(jq -j '"\(.name)/\(.version)"' package.json)/index.html"
)}
alias mkd='mkdoc'

# PHP static code analysis - https://github.com/phan/phan - https://github.com/cloudflare/docker-phan
phan() { docker run -v "$PWD":/mnt/src --rm -u "$(id -u):$(id -g)" cloudflare/phan:latest $@; return $?; }

# export GOPATH="$HOME/Development/go"
# export VAGRANT_DEFAULT_PROVIDER=libvirt

# Aliases: Server & DevOps
alias ssh='LANGUAGE="en" LANG="C" LC_MESSAGES="C" ssh' # prevent lang issues on remote servers
alias gce='until gce-ssh; do echo "Try again"; sleep 3; done '
alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods -o wide'
alias kgs='kubectl get services -o wide'
alias kgd='kubectl get deployments -o wide'
alias kd='kubectl describe'
alias kr='kubectl rollout status deployments/'
alias krs='kubectl rollout status deployments/'
alias krus='kubectl rollout undo deployments/'
alias ke='kubectl exec'
alias kp='kubectl proxy'
alias kpass='NODE_PATH=$HOME/.config/yarn/global/node_modules node -e "console.log((require(\"js-yaml\").safeLoad(fs.readFileSync(\"/home/max/.kube/config\", \"utf8\"))).users[0].user[\"auth-provider\"].config[\"access-token\"])"' # get auth token for k8s dashboard
# alias terraform='docker run -ti --rm -v $(pwd):/data -v $HOME/.google-cloud-sdk:/home/tf/google-cloud-sdk:ro -v $HOME/.kube:/home/tf/.kube:ro local/terraform'
alias t='terraform'

# Aliases: Misc
alias getip='curl -4 https://labs.wearegenki.com/ip' # Get public/WAN IP
alias getip6='curl -6 icanhazip.com'
alias getptr='curl -4 icanhazptr.com'
alias screenoff='sleep 1 && xset dpms force off'
alias m='mplayer'
alias gpaste='gpaste-client'

# Aliases: Git
alias g='git'
alias gl='git pull --prune' # Pull updates
alias gll='for dir in */; do (echo -e "\n\033[1;36m$dir\033[0m"; cd $dir && git pull --prune); done' # Pull updates from sub directories
# 1. Configure upstream remote - ref: https://help.github.com/articles/configuring-a-remote-for-a-fork/
# 2. Sync fork with upstream: run ggll - ref: https://help.github.com/articles/syncing-a-fork/
alias ggll='git fetch upstream && git merge upstream/master master'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative --all" # Simple log
alias glgg='git log --stat master@{1} master' # Detailed log
alias gld='git diff --stat master@{1} master' # Show changes since last pull
alias gldd='git log --reverse --no-merges --stat @{1}..' # Show changes since last pull
alias ga='git add'
alias gp='git push'
alias gd='git diff'
alias gdd='git diff --staged'
alias gdt='git difftool'
alias gc='GIT_EDITOR="vim +startinsert" git commit --verbose'
alias gca='gc --all'
alias gco='git checkout' # also see gchkout() below
alias gb='git branch'
alias gm='git merge'
alias gt='git tag'
alias gs='git status -sb'
alias grm='git ls-files --deleted -z | xargs -0 git rm'
# switch between master<>dev or checkout branch (creating it if necessary)
gchkout() {
  if [ -z "$1" ]; then
    [[ $(git_current_branch) = "master" ]] && git checkout dev || git checkout master
  else
    git checkout -b "$1" 2> /dev/null || git checkout "$1"
  fi
}
alias gg='gchkout'
# Show all git related aliases
galias() { alias | grep 'git' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Aliases: Docker
alias d='docker'
alias di='docker images'
alias dps='docker ps'           # Show running containers
alias dpa='docker ps -a'        # Show all containers including stopped
alias ds='docker stats $(docker ps -q)' # Monitor all containers
alias dcd='sudo sh /etc/dnsmasq.d/update-docker-dns.sh' # Update DNS with running docker containers
alias dr='docker run -ti --rm'  # Run interactively then remove
alias dra='docker run -ti --rm alpine:edge sh'
alias dp='docker pull'          # Pull image from the hub.docker.com
alias dl='docker ps -l -q'      # Get latest container ID
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'" # Get container IP
alias drm='docker rm $(docker ps -a -q)' # Remove stopped containers
alias drmi='docker rmi $(docker images -q -f dangling=true)' # Remove untagged images
alias drmv='docker volume ls -qf dangling=true | xargs -r docker volume rm' # Remove orphaned volumes
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
# Update all docker images
dup() { docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}'| grep -v "local/" | xargs -L1 docker pull; }
# Enter docker container or execute command
de() { if [ -z "$2" ]; then docker exec -ti -u root "$1" /bin/sh -c "export TERM=xterm; exec sh"; else docker exec "$1" "$2"; fi }
# Show all docker related aliases
dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Upadte ALL the things!
#alias pp-aws='sudo pip install --upgrade awscli aws-shell'
alias pp-gce='echo "y"| gcloud components update'
alias pp-zsh='(cd ~/.oh-my-zsh; exec git pull)'
#alias pp-npm='sudo npm -g update'
alias pp-yarn='yarn global upgrade'
alias pp-git='(cd "$HOME"/Development/0__github_projects; gll)'
#alias ppp='pp -y; pp-aws; pp-gce; pp-zsh; pp-git; pp-npm; dup && drmi'
# alias ppp='pp -y; pp-gce; pp-zsh'
alias ppp='pp -y; pp-gce; pp-zsh; dup; pp-yarn; pp-git'

# Paths
# export PATH=$HOME/.google-cloud-sdk/bin:$HOME/.config/yarn/global/node_modules/.bin${PATH:+:${PATH}}
export PATH="$HOME/.config/yarn/global/node_modules/.bin${PATH:+:${PATH}}"

# Node.js
export NODE_PRESERVE_SYMLINKS=1
# export NODE_PATH=$NODE_PATH:$HOME/Development

# Google Cloud SDK
source "/home/max/.google-cloud-sdk/path.zsh.inc"
source "/home/max/.google-cloud-sdk/completion.zsh.inc"

# Mongoose OS (electronics dev platform)
#PATH="$PATH:/home/max/.mos/bin"

# Tmux
#test -z "$TMUX" && (echo "tmux ls" && tmux ls)

# iBus Japanese input
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# Private configs
[[ -f ~/.aliases.PRIVATE.sh ]] && . ~/.aliases.PRIVATE.sh
