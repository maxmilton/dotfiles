# Notes

## Useful Commands

```sh
# show important messages from this boot
journalctl -b -f -n 1000 --priority 0..5
```

```sh
rg --no-ignore --hidden
```

```sh
rg --context 3 --max-columns 80 --max-columns-preview
```

```sh
# recursively set directory permissions to 700
fd --type d --hidden --no-ignore --exec chmod -c 700 {}
```

```sh
# DO NOT USE; fd can't filter out executable files
# recursively set ALL file permissions to 600
#fd --type f --hidden --no-ignore --exec chmod -c 600 {}
```

```sh
# recursively set file permissions to 600 (excluding executables)
find -O3 . -type f ! -executable -exec chmod -c 600 {} \;
```

```sh
# recursively set file permissions to 700 (executables only)
fd --type x --hidden --no-ignore --exec chmod -c 700 {}
```

```sh
# remove broken symlinks in dir
find -L . -name . -o -type d -prune -o -type l -exec /bin/rm -rf {} \;
```

```sh
# remove node_modules dirs recursively
fd --type directory --hidden --no-ignore-vcs --exec /bin/rm -rf {} \; node_modules .
```

```sh
# remove yarn-error.log files recursively
fd --type file --hidden --exec /bin/rm -rf {} \; yarn-error.log .
```

```sh
curl https://ifconfig.me/all
```

```sh
# debug bash script
env PS4="\$(if [[ \$? == 0 ]]; then echo \"\033[0;33mEXIT: \$? ✔\"; else echo \"\033[1;91mEXIT: \$? ❌\033[0;33m\"; fi)\n\nSTACK:\n\${BASH_SOURCE[0]}:\${LINENO}\n\${BASH_SOURCE[*]:1}\n\033[0m" bash -x
```

```sh
# remove missing files from git working tree
git ls-files --deleted -z | xargs -0 git rm
```

```sh
```
