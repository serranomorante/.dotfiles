#
# ~/.bashrc
#

# All this file will be source by bass fish plugin in config.fish
# ---------------------------------------------------------------

# The line below is commented because it wasn't working with
# bass fish plugin.

# If not running interactively, don't do anything
# [[ $- != *i* ]] && return

# alias ls='ls --color=auto'
alias ls='eza -1 -l --icons always --color always'
alias grep='grep --color=auto'

# Clear a terminal screen for real
# https://stackoverflow.com/a/5367075
alias cls='printf "\033c"'

# path env variables
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/bin:$PATH"
# This fixes poetry not being found
export PATH="$HOME/.local/bin:$PATH"
# Add pynvim to path
export PATH="/usr/lib/python3.11/site-packages:$PATH"
# For go packages
export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"

# system env variables
export SYSTEMD_PAGER=""
# https://wiki.archlinux.org/title/Neovim#Use_as_a_pager
# export PAGER="nvimpager"

# fzf use df instead of find
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_DEFAULT_OPTS="--layout=reverse --border"

# Wireplumber logging
# 0. critical warnings and fatal errors (C & E in the log)
# 1. warnings (W)
# 2. normal messages (M)
# 3. informational messages (I)
# 4. debug messages (D)
# 5. trace messages (T)
export WIREPLUMBER_DEBUG=3

# aliases
alias config='/usr/bin/git --git-dir=/home/serranomorante/.dotfiles/ --work-tree=/home/serranomorante'

alias vim='nvim'

export SYSTEM_DEFAULT_NODE_VERSION=$(volta list node | grep "default" | cut -d "@" -f 2 | cut -d " " -f 1)

alias work="~/.config/tmux/scripts/work.sh"
alias conf="~/.config/tmux/scripts/config.sh"

# https://github.com/mfussenegger/nvim-dap/blob/e64ebf3309154b578a03c76229ebf51c37898118/doc/dap.txt#L960
# Available log levels:
# TRACE
# DEBUG
# INFO
# WARN
# ERROR
export DAP_LOG_LEVEL=ERROR
export LSP_LOG_LEVEL=ERROR
