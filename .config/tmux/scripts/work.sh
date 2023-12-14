#!/bin/bash

# On my .bashrc file:
# alias work="~/.config/tmux/scripts/work.sh"

session_name="work"
foam="foam"
nvim="nvim"
gems="gems"
wait_for_shell=0.3

tmux new-session -d -n $foam -s $session_name # create session, name window and detach

# setup "foam" window
# ---------------------
sleep $wait_for_shell # wait for shell to load

tmux send-keys -t "$session_name:$foam" "z foam" Enter # cd into directory

tmux send-keys -t "$session_name:$foam" "vim" Enter

# setup "nvim" window
# ---------------------
tmux new-window -t $session_name -n $nvim # this will automatically focus the new window

sleep $wait_for_shell

tmux send-keys -t "$session_name:$nvim" "z nvim" Enter # cd into directory

tmux send-keys -t "$session_name:$nvim" "vim" Enter

# setup "gems" window
# ---------------------
tmux new-window -t $session_name -n "$gems"

sleep $wait_for_shell

tmux send-keys -t "$session_name:$gems" "z gems" Enter
tmux send-keys -t "$session_name:$gems" "vim" Enter

tmux split-window -t $session_name -h -p 30

sleep $wait_for_shell

tmux send-keys -t $session_name "z gems" Enter

# tmux select-window -t "$session_name:$nvim" # focused window

# Open your session
# ---------------------
tmux attach-session -t $session_name
