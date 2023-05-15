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
fd --type d --hidden --no-ignore --exec chmod 700 {}'
```

```sh
# DO NOT USE; fd can't filter out executable files
# recursively set ALL file permissions to 600
#fd --type f --hidden --no-ignore --exec chmod 600 {}
```

```sh
# recursively set file permissions to 600 (excluding executables)
find -O3 . -type f ! -executable -exec chmod 600 {} \;
```

```sh
# recursively set file permissions to 700 (executables only)
fd --type x --hidden --no-ignore --exec chmod 700 {}
```

```sh
# remove broken symlinks in dir
find -L . -name . -o -type d -prune -o -type l -exec /bin/rm -rf {} \;
```

```sh
# remove node_modules dirs recursively
fd --type directory --hidden --no-ignore-vcs --exec /bin/rm -rf {} \;node_modules .'
```

```sh
# remove yarn-error.log files recursively
fd --type file --hidden --exec /bin/rm -rf {} \; yarn-error.log .
```

```sh
curl https://ifconfig.me/all
```

```sh
# ip info with colour highlighting
ip -c addr
```

```sh
```
