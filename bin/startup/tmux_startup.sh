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

lay_doormat(){
    # formats a tmux session stored under $session
    set_greeting # set $Greeting based on TOD
    window="Good $Greeting"

    tmux select-window -t $session:0
    # creating a weather view on right quater
    tmux split-window -h -p 25
    tmux send-keys 'cd && clear && curl --silent -fL https://wttr.in?Fn' Enter

    # creating a central vim pane taking up half the screen and a little box on the top left
    tmux select-pane -t 0
    tmux split-window -h -p 66
    tmux select-pane -t 0
    tmux split-window -v -p 90

    # clearing bottom left
    tmux select-pane -t 1
    tmux send-keys 'cd && clear' C-m
    # writing quote to top left
    tmux select-pane -t 0
    tmux send-keys 'cd && clear && ~/.dotfiles/bin/startup/quote.sh' Enter
    # opening vim
    tmux select-pane -t 2
    tmux send-keys 'cd && clear && vim' C-m
    # renaming based on TOD
    tmux rename-window -t $session:0 "$window"
}

session="doormat"


if [[ ! tmuxhas-session -t $session 2>/d ]] ; then
    # no server
    tmux new-session -d -t "$session" 
    lay_doormat
else
    # existing server
    cur_session=$(tmux list-sessions 2>/dev/null | awk '{print $1}' | cut -d ":" -f 1)
    if [[ "$cur_session" == "$session" ]] ; then
        # check to see if window is set up
        cur_window=$(tmux list-windows -t "$session" 2>/dev/null | grep Good)
        if [[ -z $cur_window ]] ; then
            # no window active
            lay_doormat
            #tmux -2 attach-session -t "$session"
        fi
    else
        # doormat exists get window
        tmux new-session -d -t "$session"
        lay_doormat
    fi
fi

