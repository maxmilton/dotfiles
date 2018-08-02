#
# BASH CONFIG
#

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi

PS1="\$(if [[ \$? == 0 ]]; then echo \"\[\033[01;32m\]:)\"; else echo \"\[\033[01;31m\]:(\"; fi) $(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]\h\[\033[01;34m\] \w \$'; else echo '\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \#'; fi) \[\033[00m\] "

# better bash auto completion
if [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'TAB:menu-complete'

# default editor
export EDITOR='vim'
export VISUAL='vim'

# colorized ls
export LS_OPTIONS='--color=auto'
eval "$(dircolors --sh)"
alias ls='ls $LS_OPTIONS'

# add sudo if not root
if [ $UID -ne 0 ]; then
  alias systemctl='sudo systemctl'
  alias journalctl='sudo journalctl'
  alias apt='sudo apt'
  alias dnf='sudo dnf'
  alias yum='sudo yum'
  alias docker-compose='sudo docker-compose'
fi

# update system packages
pp() {
  case $(awk -F "=" '/^NAME/ {print $2}' /etc/os-release | tr -d '"') in
    "Arch Linux" ) yaourt -Syu --aur ;;
    Fedora ) dnf update --refresh -y ;;
    "Debian GNU/Linux" | Ubuntu ) apt update && apt upgrade --no-install-recommends -y ;;
    "Alpine Linux" ) apk upgrade --update-cache ;;
    "CentOS Linux" | "Red Hat Enterprise Linux Server" ) yum update -y ;;
    "Container Linux by CoreOS" ) update_engine_client -update ;;
  esac
}

# Aliases: System
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias -- -='cd -'
alias s='sudo -i'
alias clr='printf "\x1Bc"'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias l='ls -aCFhlX --group-directories-first'
alias ll='ls -lh'
alias dux='du -hs | sort -h'
alias dus='du --block-size=MiB --max-depth=1 | sort -n'
alias 755='find . -type d -exec chmod 755 {} \; && echo "Done!";'
alias 644="find . -type f -not -name '.git' -not -name '*.sh' -exec chmod 644 {} \; && echo 'Done!';"
# remove all broken symlinks in dir
alias lnrm='find -L . -maxdepth 1 -type l -delete'
alias sc='systemctl'
alias scs='systemctl status'
alias scr='systemctl restart'
alias jc='journalctl'
alias jcd='journalctl --disk-usage && journalctl --verify'
alias jcdd='journalctl --vacuum-size=1G'

# Aliases: Sysadmin
alias t='terraform'
alias ti='terraform init'
alias tp='terraform plan'
alias getip='curl -4 icanhazip.com'
alias getip6='curl -6 icanhazip.com'
alias getptr='curl -4 icanhazptr.com'
alias ta='tmux attach'
alias ccze="ccze -A"

# Aliases: Containers
alias k='kubectl'
alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpa='docker ps -a'
# monitor all containers
alias ds='docker stats $(docker ps -q)'
alias dp='docker pull'
# get latest container ID
alias dl='docker ps -l -q'
# get container IP
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
# remove stopped containers
alias drm='docker rm $(docker ps -a -q)'
# remove untagged images
alias drmi='docker rmi $(docker images -q -f dangling=true)'
# remove orphaned volumes
alias drmv='docker volume ls -qf dangling=true | xargs -r docker volume rm'
alias dc='docker-compose'
# update all docker images
dup() { alias | docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}'| xargs -L1 docker pull; }
# enter docker container or execute command
de() { if [ -z "$2" ]; then docker exec -ti -u root "$1" /bin/sh; else docker exec "$1" "$2"; fi }

# Aliases: CoreOS
alias fc='fleetctl'
alias fcl='fleetctl list-units'
alias fclw='watch -n 1 fleetctl list-units'
alias fcf='fleetctl list-unit-files'
alias fcm='fleetctl list-machines'
alias ec='etcdctl'
# roll back a system upgrade if something goes bad, needs reboot
alias rollback='cgpt prioritize "$(cgpt find -t coreos-usr | grep --invert-match "$(rootdev -s /usr)")"'

# check for active tmux sessions (if tmux is installed)
command -v tmux >/dev/null 2>&1 && (echo "🔹 tmux ls" && tmux ls) || true
