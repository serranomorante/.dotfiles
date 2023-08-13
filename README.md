# .dotfiles

## Workflow

### Bash and fish interoperability

Even thought I like [fish](https://fishshell.com/docs/current/index.html) and I use it extensively, I still refuse to make it my main shell.

In my current workflow, I only use fish from inside my terminal (wezterm), leaving the rest of my system to use the default shell (bash).

As I don't want to duplicate the same env variables and aliases from my `.bashrc` file into my `config.fish`, I decided to use fish [bass](https://github.com/edc/bass) plugin. With this plugin I just need to source my `~/.bashrc` file from inside fish and it will try its best to transpile bash syntax into fish.

