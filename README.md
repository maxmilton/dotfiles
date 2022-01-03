# Max Milton's Dotfiles

Intended for use on a Linux OS. Limited support for macOS, BSD, or UNIX-like OSes. Uses [chezmoi](https://github.com/twpayne/chezmoi) to manage the dotfiles.

## Usage

### Install

1. Install `chezmoi` using your package manager or manually download the [latest release](https://github.com/twpayne/chezmoi/releases).

1. Initialise local state:
    ```sh
    chezmoi init git@github.com:MaxMilton/dotfiles.git -v
    ```

1. Optionally, run post install script:
    ```sh
    # bash
    sh $(chezmoi source-path)/.install/install.sh

    # fish
    sh (chezmoi source-path)/.install/install.sh
    ```

#### "One shot" install on ephemeral systems

1. Download [latest standalone (.tar.gz) release](https://github.com/twpayne/chezmoi/releases). Must be version >= 2
1. `chezmoi init --one-shot MaxMilton`

### Update

```sh
chezmoi update -v
```

## License

MIT. See [LICENSE](https://github.com/maxmilton/dotfiles/blob/master/LICENSE).

-----

© 2021 [Max Milton](https://maxmilton.com)
