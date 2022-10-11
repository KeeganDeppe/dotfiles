#!/bin/bash

timestamp=$(date +%m-%dT%H:%M);
timesheet="$HOME/.dotfiles/bin/timetracker/timesheet.log"

if [[ ! -e "$timesheet" ]] ; then
    touch "$timesheet"
fi

if [[ $1 == "-i" ]] ; then
    echo "I $timestamp" >> "$timesheet"
elif [[ $1 = "-o" ]] ; then
    echo "O $timestamp" >> "$timesheet"
fi
