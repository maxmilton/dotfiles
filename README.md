# Max Milton's Dotfiles

Intended for use on a Linux OS. Limited support for macOS, BSD, or UNIX-like OSes. Uses [chezmoi](https://github.com/twpayne/chezmoi) to manage the dotfiles.

## Usage

### Install

Download the latest version of `chezmoi` from <https://github.com/twpayne/chezmoi/releases> or install from source (recommended when you have a go compiler toolchain):

```sh
go get -u github.com/twpayne/chezmoi
```

Initialise the `chezmoi` local state:

```sh
chezmoi init git@github.com:MaxMilton/dotfiles.git -v
```

Run post install script

```sh
# bash
sh $(chezmoi source-path)/post-install.sh

# fish
sh (chezmoi source-path)/post-install.sh
```

### Update

```sh
chezmoi update -v
```

## Licence

The contents of this repo are MIT licensed open source. See [LICENCE](https://github.com/MaxMilton/dotfiles/blob/master/LICENCE).

-----

© 2019 [Max Milton](https://maxmilton.com)
