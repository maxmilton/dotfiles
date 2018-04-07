# XXX: Fish saves most of these commands after the first invocation and so they
# only need to be called one time initially or when updated.

# Disable welcome message
set -U fish_greeting

# VIM = <3
set -U EDITOR vim
set -U VISUAL vim

# Command line calculator
abbr --add C 'calc'

# Aliases: System
abbr --add s 'sudo -i'
abbr --add cp 'cp -i'
abbr --add mv 'mv -i'
abbr --add l 'ls --color -aCFhlX --group-directories-first'
abbr --add ll 'ls --color -hl'
abbr --add la 'ls --color -Ahl'
abbr --add lsd 'ls --color -lad */ .*/'
abbr --add ffind 'find -O3 . ! -path "node_modules" ! -path ".git" -type f -iname "*xx*"'
abbr --add find 'find -O3'
abbr --add dux 'du -hs | sort -h'
abbr --add dus 'du --block-size=MiB --max-depth=1 | sort -n'
abbr --add 775 'find . -type d -exec chmod 775 {} \; and echo "Done!"'
abbr --add 755 'find . -type d -exec chmod 755 {} \; and echo "Done!"'
abbr --add 700 'find . -type d -exec chmod 700 {} \; and echo "Done!"'
abbr --add 664 'find . -type f -not -name ".git" -not -name "*.sh" -not -executable -exec chmod 664 {} \; and echo "Done!"'
abbr --add 644 'find . -type f -not -name ".git" -not -name "*.sh" -not -executable -exec chmod 644 {} \; and echo "Done!"'
abbr --add 600 'find . -type f -not -name ".git" -not -name "*.sh" -not -executable -exec chmod 600 {} \; and echo "Done!"'
abbr --add scs 'sc status'
abbr --add scr 'sc restart'

# Aliases: Directories
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'
abbr --add ..... 'cd ../../../..'
abbr --add ...... 'cd ../../../../..'
abbr --add ....... 'cd ../../../../../..'

# Aliases: Arch Linux
abbr --add p 'yaourt'

# Aliases: Development
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

# Generate JSDoc and open result in browser
abbr --add mkd='mkdoc'

# Aliases: Server & DevOps
abbr --add gce 'while not gce-ssh; echo "trying again..."; sleep 3; end'
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
abbr --add t 'terraform'

# Aliases: Misc
abbr --add getip 'curl -4 https://labs.wearegenki.com/ip' # Get public/WAN IP
abbr --add getip6 'curl -6 icanhazip.com'
abbr --add getptr 'curl -4 icanhazptr.com'

# Aliases: Git
abbr --add g 'git'
abbr --add gl 'git pull --prune' # Pull updates
# 1. Configure upstream remote - ref: https://help.github.com/articles/configuring-a-remote-for-a-fork/
# 2. Sync fork with upstream: run ggll - ref: https://help.github.com/articles/syncing-a-fork/
abbr --add ggll 'git fetch upstream; and git merge upstream/master master'
abbr --add glg "git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative --all" # Simple log
abbr --add glgg 'git log --stat master@{1} master' # Detailed log
abbr --add gld 'git diff --stat master@{1} master' # Show changes since last pull
abbr --add gldd 'git log --reverse --no-merges --stat @{1}..' # Show changes since last pull
abbr --add ga 'git add'
abbr --add gp 'git push'
abbr --add gd 'git diff'
abbr --add gdd 'git diff --staged'
abbr --add gdt 'git difftool'
abbr --add gca 'gc --all'
abbr --add gco 'git checkout' # also see gchkout() below
abbr --add gb 'git branch'
abbr --add gm 'git merge'
abbr --add gt 'git tag'
abbr --add gs 'git status -sb'
abbr --add grm 'git ls-files --deleted -z | xargs -0 git rm'
abbr --add gg 'gchkout'

# Aliases: Docker
abbr --add d 'docker'
abbr --add di 'docker images'
abbr --add dps 'docker ps'           # Show running containers
abbr --add dpa 'docker ps -a'        # Show all containers including stopped
abbr --add ds 'docker stats (docker ps -q)' # Monitor all containers
abbr --add dr 'docker run -ti --rm'  # Run interactively then remove
abbr --add dra 'docker run -ti --rm alpine:edge sh'
abbr --add dp 'docker pull'          # Pull image from the hub.docker.com
abbr --add dl 'docker ps -l -q'      # Get latest container ID
abbr --add dip "docker inspect --format '{{ .NetworkSettings.IPAddress }}'" # Get container IP
abbr --add drmv 'docker volume ls -qf dangling=true | xargs -r docker volume rm' # Remove orphaned volumes
abbr --add dc 'docker-compose'
abbr --add dcu 'docker-compose up'
abbr --add dcd 'docker-compose down'
abbr --add dcr 'docker-compose down; and docker-compose up'

# Update ALL the things!
abbr --add ppp 'pp; pp-gce; pp-fish; dup; pp-yarn; pp-git'

# Google Cloud SDK
set -U fish_user_paths $HOME/.google-cloud-sdk/bin $fish_user_paths

# Node.js
set -U fish_user_paths $HOME/.config/yarn/global/node_modules/.bin $fish_user_paths
set -U NODE_PRESERVE_SYMLINKS 1

# Fisherman plugin: fzf
set -U FZF_LEGACY_KEYBINDINGS 0
