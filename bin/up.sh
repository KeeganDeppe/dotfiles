#!/usr/bin/env bash

ft_seconds=$(cat /proc/uptime | awk '{print $1}' | xargs printf '%d' 2>/dev/null) # floored int total
ft_minutes=$(($ft_seconds/60)) 
ft_hours=$(($ft_minutes/60))

echo $ft_hours $ft_minutes $ft_seconds
if [[ $ft_hours -gt 1 ]] ; then
    # display with leading hours
    rem_mins=$(($ft_minutes % 60)) # get remaining mins
    printf '%dH %dM' $ft_hours $rem_mins
else
    # display with leading minutes
    rem_secs=$(($ft_seconds % 60)) # get remaining mins
    printf '%dM %dS' $ft_minutes $rem_secs
fi
