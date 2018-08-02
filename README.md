# Max Milton's Dotfiles

Intended for use with a Linux OS. Limited support for macOS, BSD, and UNIX-like OS.

## Usage

_NOTE: Requires [GNU Stow](https://www.gnu.org/software/stow/) to automatically symlink config packages._

View help text:

```sh
./dotfiles.sh -h
```

Dry run with default packages:

```sh
./dotfiles.sh
```

Install default packages:

```sh
./dotfiles.sh -i
```

Install a specific package:

```sh
./dotfiles.sh -i fish
```

Install multiple specific packages:

```sh
./dotfiles.sh -i bash git yarn
```

## Licence

The contents of this repo are MIT licensed open source. See [LICENCE](https://github.com/MaxMilton/dotfiles/blob/master/LICENCE).

-----

© 2018 [Max Milton](https://maxmilton.com)
