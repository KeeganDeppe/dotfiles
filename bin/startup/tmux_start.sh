#!/usr/bin/env bash

print_output=false

while getopts "s" arg; do
    case $arg in
        s)
            print_output=true
            ;;
    esac
done    

SESSION="doormat" # welcom session name
START_SERVER=false

set_session() {
    # sets $SESSION variable to doormat
    active_sessions=$(tmux list-sessions 2>/dev/null)
    if [[ ! -z "$active_sessions" ]] ; then
        # active sessions
        session=$(echo "$active_sessions" | grep "$SESSION" | cut -d ':' -f 1 2>/dev/null)
# tmux doormat script
        if [[ "$session" != "$SESSION" ]] ; then
            # door mat doesn't exist
            START_SERVER=true
        fi
    else
        START_SERVER=true
    fi
    
    if $START_SERVER ; then
        # need to start server
        tmux new-session -d -s "$SESSION"
        tmux set-hook -t "$SESSION" client-attached 'run-shell ~/.dotfiles/bin/startup/lay_doormat.sh'
    fi
}

set_session

if $print_output ; then
    echo "SESSION=$SESSION"
fi
