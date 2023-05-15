# FISH GLOBALS & ALIASES; EXTRAS FOR DEVELOPMENT ENVIRONMENT
#
# Fish compiles and saves these commands so they only need to be called once
# initially and after any change to this file.

# Show lines as they are read
set fish_trace 1

set -l DIR (status dirname)
source "$DIR"/config-oneshot.fish

set -U hydro_color_prompt magenta

# Set user paths in reverse order of priority
fish_add_path "$HOME"/.foundry/bin

fish_add_path "$HOME"/.local/share/pnpm
set -U PNPM_HOME "$HOME"/.local/share/pnpm

fish_add_path "$HOME"/.bun/bin
set -U BUN_INSTALL "$HOME"/.bun
set -Ux DISABLE_BUN_ANALYTICS 1

fish_add_path "$HOME"/.local/bin

# # Docker
# # abbr --add d 'docker'
# # abbr --add dcc 'docker-compose'
# abbr --add di 'docker images'
# abbr --add drm 'docker system prune'
# # show containers
# abbr --add dps "docker ps -a --format {{"'table {{.Names}}\t{{.Image}}\t{{.Status}}'"}}"
# # abbr --add dpss "docker ps -q | xargs docker inspect --format {{"'{{.Config.Hostname}} - {{.Name}} - {{.NetworkSettings.IPAddress}}'"}}"
# # monitor all containers
# # abbr --add ds 'docker stats (docker ps -q)'
# # abbr --add dr 'docker run --rm -ti'
# # abbr --add drr 'docker run --rm -ti --volume="$PWD":/data alpine:edge sh'
# # abbr --add dp 'docker pull'
# # get latest container ID
# # abbr --add dl 'docker ps -l -q'
# # get container IP
# # abbr --add dip "docker inspect --format '{{"{{"}} .NetworkSettings.IPAddress {{"}}"}}'"
# # remove orphaned volumes
# #abbr --add drmv 'docker volume ls -qf dangling=true | xargs -r docker volume rm'
# # get shell in host via docker
# #abbr --add dnse 'docker run -it --rm --privileged --pid=host justincormack/nsenter1'

# # Development
# abbr --add j 'pnpm'
# abbr --add ju 'pnpm upgrade --interactive --latest -r'
# abbr --add ji 'pnpm install --prefer-frozen-lockfile=false'
# abbr --add jr '/bin/rm pnpm-lock.yaml; and pnpm install'
# abbr --add jrr '/bin/rm -rf pnpm-lock.yaml **/node_modules; pnpm install'
# abbr --add jrrr '/bin/rm -rf pnpm-lock.yaml **/{dist,node_modules}; pnpm install'
# abbr --add jb 'pnpm run build'
# abbr --add jd 'pnpm run dev'
# abbr --add jt 'pnpm run lint; and TZ=UTC pnpm run test'
# abbr --add jtt 'TZ=UTC pnpm run test:e2e'
# # abbr --add js 'pnpm run serve'
# abbr --add jii 'pnpm info'

# # abbr --add j 'pnpm'
# # abbr --add ju 'pnpm upgrade --interactive --latest -r'
# abbr --add bi 'bun install'
# # abbr --add jr '/bin/rm pnpm-lock.yaml; and pnpm install'
# # abbr --add jrr '/bin/rm -rf pnpm-lock.yaml **/node_modules; pnpm install'
# # abbr --add jrrr '/bin/rm -rf pnpm-lock.yaml **/{dist,node_modules}; pnpm install'
# abbr --add bb 'bun run build'
# abbr --add bd 'bun run dev'
# abbr --add bt 'bun run lint; and TZ=UTC pnpm run test'
# abbr --add btt 'TZ=UTC bun run test:e2e'
# # abbr --add js 'pnpm run serve'
# # abbr --add jii 'pnpm info'

# # Git
# abbr --add g 'git'
# # edit all files with changes
# # abbr --add ge 'vim -p (git diff --name-only)'
# abbr --add gs 'git status --short --branch --show-stash'
# abbr --add gp 'git pull --prune'
# abbr --add gps 'git pull --prune --autostash'
# # 1. Configure upstream remote - ref: https://help.github.com/articles/configuring-a-remote-for-a-fork/
# #  ↳ git remote add upstream <repo>
# # 2. Sync fork with upstream: run gpp - ref: https://help.github.com/articles/syncing-a-fork/
# # abbr --add gpp 'git fetch upstream; and git merge upstream/master master; and git push origin master'
# abbr --add gl "git log --graph --pretty=format:'%C(yellow)%h%Creset%C(blue)%d%Creset %C(white bold)%s%Creset %C(white dim)(by %an %ar)%Creset'"
# # abbr --add gll 'git log --oneline -n 40'
# # abbr --add glll 'git log --graph --abbrev-commit --date=relative'
# abbr --add ga 'git add'
# abbr --add gd 'git diff'
# # abbr --add gdt 'git difftool'
# # abbr --add gdd 'git diff --staged'
# # see changes in origin
# # abbr --add gpdo 'git diff master..origin/master'
# # see changes in upstream
# # abbr --add gpdu 'git fetch upstream; git diff master..upstream/master'
# # review changes from last pull
# # abbr --add gpd "git log --reverse --no-merges --stat '@{1}..'"
# # see unpushed commits
# # abbr --add gout 'git log --stat "@{u}"..'
# # see unpushed commits on all branches
# # abbr --add gouta 'git log --stat --branches --not --remotes'
# # see unpulled commit
# # abbr --add gin 'git log --stat .."@{u}"'
# abbr --add gc 'git commit --verbose'
# abbr --add gca 'git commit --verbose --all'
# abbr --add gco 'git checkout'
# abbr --add gg 'git checkout (git branch --all --format "%(refname:lstrip=2)" | fzy --lines max)'
# abbr --add gb 'git branch --all'
# # abbr --add gm 'git merge'
# # abbr --add gt 'git tag'
# # remove missing files
# # abbr --add grm 'git ls-files --deleted -z | xargs -0 git rm'

# # Google Cloud SDK
# #abbr --add gcloud_instances 'gcloud compute instances list --project wearegenkicom'
