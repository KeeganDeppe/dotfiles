#!/usr/bin/env bash

uptime=$(( $(date +%s) - $(date -d "$(uptime -s)" +%s)))
ft_minutes=$(($uptime/60)) 
ft_hours=$(($ft_minutes/60))

#echo $ft_hours $ft_minutes $ft_seconds
if [[ $ft_hours -gt 0 ]] ; then
    # display with leading hours
    ft_mins=$(($ft_minutes % 60)) # get remaining mins
    printf '%dH %dM' $ft_hours $ft_mins
else
    # display with leading minutes
    printf '%dM' $ft_minutes
fi
