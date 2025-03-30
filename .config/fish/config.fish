umask 077

status is-interactive || exit

abbr .. -r '^\.\.+$' -f multicd
abbr rm 'gio trash'
abbr cp 'cp -i'
abbr mv 'mv -i'
abbr ls eza
abbr l 'eza -laF --group-directories-first'
abbr ll 'eza -laBF --group-directories-first'
abbr ld 'eza --tree --only-dirs'
abbr find fd
abbr ff 'fd -H --no-ignore'
abbr grep rg
abbr rr 'rg -.S -C1 -M80 --max-columns-preview --no-ignore'
abbr ip 'ip -c'
abbr h helix
abbr p paru
abbr curl "curl -vv -H 'Cache-Control: no-cache'"
abbr mm 'mpv --no-video'
abbr duckdb 'duckdb -safe -readonly'

abbr bi 'bun install'
abbr br 'rm -f bun.lock*; rm -rf **/node_modules; bun install -f'
abbr bu "bunx --bun taze -rflIw --ignore-paths='**/*.bak/**' latest"
abbr bb 'bun run build'
abbr bd 'bun run dev'
abbr bt 'bun run lint; and bun run test'
abbr btt 'bun run test:e2e'
abbr yi 'bunx yarn info'

abbr gs 'git status --short --branch --show-stash'
abbr gd 'git diff'
abbr gdd 'git diff --staged'
abbr gb 'git branch -vv --all'
abbr gp 'git pull --prune --autostash'
abbr gm 'git merge --autostash'
abbr gc 'git commit -v'
abbr gca 'git commit -v --all'
abbr gco 'git checkout'
