umask 077

status is-interactive || exit

abbr .. -r '^\.\.+$' -f multicd
abbr rm 'gio trash'
abbr cp 'cp -i'
abbr mv 'mv -i'
abbr ls exa
abbr l 'exa -lFa --group-directories-first'
abbr ll 'exa -lFa --bytes --group-directories-first'
abbr ld 'exa --tree --only-dirs'
abbr find fd
abbr ff 'fd --no-ignore --hidden'
abbr grep rg
abbr rr 'RIPGREP_CONFIG_PATH=~/.ripgreprc rg --no-ignore --hidden'
abbr dux 'du -bh --max-depth=1 | sort -h'
abbr p paru
abbr hh 'history --merge'
abbr h helix
abbr ip 'ip -c'
abbr curl "curl -vv -H 'Cache-Control: no-cache'"
abbr get 'aria2c --optimize-concurrent-downloads --dir ~/Downloads'

abbr j pnpm
abbr ju 'pnpm upgrade --interactive --latest -r'
abbr ji 'pnpm install --prefer-frozen-lockfile=false'
abbr jr 'rm pnpm-lock.yaml; and pnpm install'
abbr jrr 'rm -rf pnpm-lock.yaml **/{dist,node_modules}; pnpm install'
abbr jb 'pnpm run build'
abbr jd 'pnpm run dev'
abbr jt 'pnpm run lint; and TZ=UTC pnpm run test'
abbr jtt 'TZ=UTC pnpm run test:e2e'
abbr bi 'bun install'
abbr br 'rm -rf bun.lockb **/node_modules; bun install'
abbr bu 'bunx taze --interactive -r'
abbr bb 'bun run build'
abbr bd 'bun run dev'
abbr bt 'bun run lint; and TZ=UTC bun run test'
abbr btt 'TZ=UTC bun run test:e2e'

abbr gs 'git status --short --branch --show-stash'
abbr gp 'git pull --prune'
abbr gps 'git pull --prune --autostash'
abbr gm 'git merge'
abbr gma 'git merge --autostash'
abbr ga 'git add'
abbr gd 'git diff'
abbr gc 'git commit -v'
abbr gca 'git commit -v --all'
abbr gco 'git checkout'
