# FreeBSD Setup

```sh
# System update
doas -s
freebsd-update fetch install && pkg update && pkg upgrade -y

doas sh -c 'freebsd-update fetch install && pkg update && pkg upgrade -y'
```
