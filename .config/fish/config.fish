if status is-interactive
    source ~/.bashrc

    # Commands to run in interactive sessions can go here
    set fish_greeting ""

    # Set vi key bindings
    set fish_key_bindings fish_vi_key_bindings
    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block blink
    # Set the insert mode cursor to a line
    set fish_cursor_insert line blink
    # Set the replace mode cursor to an underscore
    set fish_cursor_replace_one underscore blink
    # The following variable can be used to configure cursor shape in
    # visual mode, but due to fish_cursor_default, is redundant here
    set fish_cursor_visual block blink
    # https://github.com/fish-shell/fish-shell/issues/5894
    set -g fish_escape_delay_ms 10

    # Force cursor switch
    set fish_vi_force_cursor true

    # Use fzf to search history
    function reverse_history_search
      history | fzf --no-sort -q "$(commandline -b)" | read -l command
      if test $command
        commandline -rb $command
      end
    end

    function fish_user_key_bindings
      bind -M default / reverse_history_search
    end

    # Add ruby gems
    rbenv init - fish | source

    # Setup pyenv for fish
    # See https://github.com/pyenv/pyenv#set-up-your-shell-environment-for-pyenv
    pyenv init - | source

    # Enable auto-activation of virtualenvs
    # See https://github.com/pyenv/pyenv-virtualenv#installing-as-a-pyenv-plugin
    # I'm commenting this line for now because I stopped liking pyenv-virtualenv
    # and now I just use poetry.
    # pyenv virtualenv-init - | source

    # https://github.com/ajeetdsouza/zoxide?tab=readme-ov-file#installation
    zoxide init fish | source

    # https://github.com/direnv/direnv/blob/master/docs/hook.md#fish
    direnv hook fish | source
end
