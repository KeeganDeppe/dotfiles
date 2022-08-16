#!/usr/bin/env bash
# this script enables water tracking in tmux status bar via a simple command
# tracking resets everyday at midnight local time
# to inc/dec water consumed just call water XX where XX is any integer amount of ounces to change your total by
#       it is really only ever exepected to use negatives to fix mistakes
# the file writes like a log where the last entry is total consumed and the difference between two consecutive entries is the water consumed in that entry
# i.e
# 10:00:01 0 starts off at 0 in a new day
# 10:14:21 16 drank 16 ounces of water so it goes up
# 11:10:21 48 drank 32 more ounces of water so new total is 48

# setting up vars
declare waterfile
declare -i water_intake
declare output

curtime=$(timedatectl | grep Local | cut -d '-' -f 2-) # getting date to MM-DD HH:MM:SS TMZ
date=$(echo $curtime | awk '{print $1}') # for filename
time=$(echo $curtime | awk '{print $2}') # for timestamp

waterfile="$HOME/.dotfiles/bin/water/waterintake/$date" # makes it easy to reset on each new day

mkdir -p "$HOME/.dotfiles/bin/water/waterintake"

# waterfile layout
# 1)int in ozs for water consumption
# 2...) TIMESTAMP change

# update func
update() {
    printf '%s: %s\n' "$time" "$water_intake" >> "$waterfile"
}

# getting current water level
get_water_intake() {
    if [[ -f $waterfile ]] ; then
        water_intake=$(cat $waterfile | tail -n 1 | awk '{print $2}')
    else
        water_intake=0
    fi
}

reset_water_intake() {
    water_intake=0
    update
}

colorize_water_intake() {
    # sends water intake level through conditionals to be colorized
    dflt='#[default]'
    if [[ $water_intake -lt 32 ]] ; then
        color='#[fg=color1]' # red
    elif [[ $water_intake -lt 64 ]] ; then
        color='#[fg=color3]' # bad yellow
    elif [[ $water_intake -lt 96 ]] ; then
        color='#[fg=color226]' # pale yellow
    elif [[ $water_intake -lt 128 ]] ; then
        color='#[fg=color10]' # light green
    else
        color='#[fg=color21]' # blue 
    fi
    output="${color}\uf6aa ${water_intake}${dflt}"
}

# checking for/creating missing files
if [[ ! -f $waterfile ]] ; then
    # water intake file doesn't exist
    reset_water_intake
fi

# evaluating arguements
get_water_intake
if [[ -z $1 ]] ; then
    colorize_water_intake # optional color codes based on total consumption
    echo -e $output # no args is basic echo
else
    water_intake="$((water_intake + $1))" # provided value to inc/dec water intake by
    update
fi
