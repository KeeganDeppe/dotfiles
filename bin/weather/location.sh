#!/usr/bin/env bash
# creates a hidden file of your location details based on your address, will expand to support addition via zip codes

if [[ -z $1 ]] ; then
    # called without args
    CURRENT_LOCATION=$(curl --silent http://ip-api.com/csv)

    STATE_CODE=$(echo "$CURRENT_LOCATION" | cut -d, -f 4)
    CITY=$(echo "$CURRENT_LOCATION" | cut -d , -f 6)
    LAT=$(echo "$CURRENT_LOCATION" | cut -d , -f 8)
    LON=$(echo "$CURRENT_LOCATION" | cut -d , -f 9)
    printf "STATE=%s\nCITY=%s\nLAT=%s\nLON=%s\n" $STATE_CODE $CITY $LAT $LON > "$HOME/.dotfiles/bin/weather/.env.location"
fi


