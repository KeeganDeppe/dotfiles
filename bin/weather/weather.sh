#!/bin/bash
source "$HOME/.dotfiles/.priv/key"
source "$HOME/.dotfiles/bin/weather/.env.location"
source "$HOME/.dotfiles/bin/weather/.env.weather"
# API_KEY=$(cat "$HOME/.dotfiles/bin/weather/.priv/key")
# getting weather
CUR_TIMESTAMP=$(date +%s)
# only update weather every 30 seconds

if [[ $CUR_TIMESTAMP -gt $EXPIRATION  || -z $EXPIRATION ]] ; then
    WEATHER=$(curl --silent http://api.openweathermap.org/data/2.5/weather\?lat="$LAT"\&lon="$LON"\&appid="$API_KEY"\&units=imperial)

    echo $WEATHER
    TEMP=$(echo $WEATHER | jq -r '.main.temp')
    HUMIDITY=$(echo $WEATHER | jq -r '.main.humidity')
    ICON=$(echo $WEATHER | jq -r '.weather[0].icon')
    EXPIRATION=$(($CUR_TIMESTAMP+30))

    printf 'TEMP=%s\nHUMIDITY=%s\nICON=%s\nEXPIRATION=%s\n' "$TEMP" "$HUMIDITY" "$ICON" "$EXPIRATION" >"$HOME/.dotfiles/bin/weather/.env.weather"
fi
