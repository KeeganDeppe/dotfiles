#!/usr/bin/env bash

set_greeting() {
    # sets the TOD variable based on time of calling
    cur_time=$(date +%H) # hour
    # this control flow will be scuffed because I need to deal with early AM = evening
    if [[ $cur_time -lt 4 || $cur_time -gt 17 ]] ; then
        # between 5:00 pm and 4:00 am
        Greeting="Evening"
    elif [[ $cur_time -lt 12 ]] ; then
        # between 4:00 am and 12:00 pm
        Greeting="Morning"
    else
        Greeting="Afternoon"
    fi
}

session="doormat"

session_exists=$(tmux list-sessions  2>/dev/null | grep $session) # get rid of "no server" error

if [[ -z $session_exists ]] ; then


    tmux new-session -d -s $session
    set_greeting
    window="Good $Greeting"

    tmux select-window -t $session:0
    tmux split-window -h -p 25
    tmux send-keys 'cd && clear && curl --silent -fL https://wttr.in?Fn' Enter
    tmux select-pane -t 0
    tmux split-window -h -p 66
    tmux select-pane -t 0
    tmux split-window -v -p 90
    tmux select-pane -t 0

    tmux send-keys 'cd && clear && quote.sh' Enter
    tmux select-pane -t 1
    tmux send-keys 'cd && clear' C-m
    tmux select-pane -t 2
    tmux send-keys 'cd && clear && vim' C-m
    tmux rename-window -t $session:0 "$window"
fi

#tmux -2 attach-session -t "$session"

