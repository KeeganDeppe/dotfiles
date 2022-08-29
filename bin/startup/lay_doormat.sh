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

format_doormat() {
    # formats doormat on entry

    set_greeting # set $Greeting based on TOD
    window="Good $Greeting"

    

    tmux select-window -t "$SESSION:0"
    # creating a weather view on right quater
    tmux split-window -h -p 40
    # creating quote area
    tmux split-window -v -p 20
    # weather
    tmux select-pane -t 1
    tmux send-keys 'c && curl --silent -fL https://wttr.in?Fn' C-m
    # quote
    tmux select-pane -t 2 
    tmux send-keys 'c && quote.sh' C-m

    # opening vim
    tmux select-pane -t 0
    tmux send-keys 'c && vim' C-m

    # renaming based on TOD
    tmux rename-window -t "$SESSION:0" "$window"
    tmux set-hook -u -t $SESSION client-attached

}

eval "$(tmux_start.sh -s)"

if [[ ! -z $SESSION ]] ; then
    # session is set
    format_doormat
fi
