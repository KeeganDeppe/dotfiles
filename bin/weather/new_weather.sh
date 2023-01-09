#!/bin/bash
#source "$HOME/.dotfiles/.priv/key"
#source "$HOME/.dotfiles/bin/weather/.env.location"
#source "$HOME/.dotfiles/bin/weather/.env.weather"
# API_KEY=$(cat "$HOME/.dotfiles/bin/weather/.priv/key")
# getting weather
CUR_TIMESTAMP=$(date +%s)
# only update weather every 30 seconds

if [[ $CUR_TIMESTAMP -gt $EXPIRATION  || -z $EXPIRATION ]] ; then
    WEATHER=$(curl --silent "http://wttr.in/${LOCATION}?format=j2" | gojq -r '.current_condition[0]')

    echo $WEATHER
    TEMP=$(echo $WEATHER | gojq -r '.temp_F')
    HUMIDITY=$(echo $WEATHER | gojq -r '.humidity')
    ICON=$(echo $WEATHER | gojq -r '.weatherCode')
    EXPIRATION=$(($CUR_TIMESTAMP+30))
    echo "TEMP: $TEMP HUMIDITY: $HUMIDITY ICON: $ICON"
    #printf 'TEMP=%s\nHUMIDITY=%s\nICON=%s\nEXPIRATION=%s\n' "$TEMP" "$HUMIDITY" "$ICON" "$EXPIRATION" >"$HOME/.dotfiles/bin/weather/.env.weather"
fi
