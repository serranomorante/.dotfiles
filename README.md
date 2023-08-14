# .dotfiles

This are my personal config files that might only make sense for my particular workflow.

Main technologies:

- [wezterm](https://wezfurlong.org/wezterm/index.html). Terminal emulator
- [neovim](https://neovim.io/). Text editor
- [fish](https://fishshell.com/docs/current/tutorial.html). Shell
- [zellij](https://github.com/zellij-org/zellij). Terminal multiplexer
- [optimus-manager](https://github.com/Askannz/optimus-manager). GPU switching on Optimus laptops
- [autorandr](https://github.com/phillipberndt/autorandr). Automate display configuration
- [i3](https://i3wm.org/). Window tiling manager
- [m2i](https://gitlab.com/enetheru/midi2input). Use midi to control your system
- [gromit-mpx](https://github.com/bk138/gromit-mpx). Draw on top of your screen
- [keyd](https://github.com/rvaiya/keyd). A key remapping daemon for linux

## Requirements

Necesary dependencies for my workflow

- [feh](https://wiki.archlinux.org/title/feh). Set your system wallpaper programatically
- [bass](https://github.com/edc/bass). To re-use .bashrc entries in fish. You must clone the repo and execute `make install`
- [jq](https://man.archlinux.org/man/jq.1.en). Command-line JSON processor
- [xgetres](https://aur.archlinux.org/packages/xgetres). Get entries from .Xresources
- [veikk-tablet-bin](https://aur.archlinux.org/packages/veikk-tablet-bin). Driver for my graphic tablet

## Workflow

### Bash and fish interoperability

Even thought I like [fish](https://fishshell.com/docs/current/index.html) and I use it extensively, I still refuse to make it my main shell.

In my current workflow, I only use fish from inside my terminal (wezterm), leaving the rest of my system to use the default shell (bash).

As I don't want to duplicate the same env variables and aliases from my `.bashrc` file into my `config.fish`, I decided to use fish [bass](https://github.com/edc/bass) plugin. With this plugin I just need to source my `~/.bashrc` file from inside fish and it will try its best to transpile bash syntax into fish.

## Plans

- **Add zellij's config files**. I still don't add them because at the moment zellij doens't support path variable expansion so I will wait until then.
- **Add wireplumber's config files**. Still in progress
- **Add pipewire's config files**. Still in progress
- **Add m2i's config files**. Still in progress
