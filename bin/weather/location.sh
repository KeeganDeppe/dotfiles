#!/usr/bin/env bash
# creates a hidden file of your location details based on your address, will expand to support addition via zip codes

usage() { echo "Usage: $0 [-z zipcode]" 1>&2; exit 1; }

if [[ $# -eq 0 ]] ; then
    # called without args
    CURRENT_LOCATION=$(curl --silent http://ip-api.com/csv)

    CITY=$(echo "$CURRENT_LOCATION" | cut -d , -f 6)
    LAT=$(echo "$CURRENT_LOCATION" | cut -d , -f 8)
    LON=$(echo "$CURRENT_LOCATION" | cut -d , -f 9)
    printf "CITY=%s\nLAT=%s\nLON=%s\n" "$CITY" $LAT $LON > "$HOME/.dotfiles/bin/weather/.env.location"
fi

while getopts "z:" arg; do
    case ${arg} in
        z)
            ZIPCODE=${OPTARG}
            source "$HOME/.dotfiles/.priv/key"
            URL="http://api.openweathermap.org/geo/1.0/zip?zip=$ZIPCODE&appid=$API_KEY"
            LOCATION=$(curl --silent "$URL")
            CITY=$(echo $LOCATION | jq -r '.name')
            LAT=$(echo $LOCATION | jq -r '.lat')
            LON=$(echo $LOCATION | jq -r '.lon')
            printf "CITY=%s\nLAT=%s\nLON=%s\n" "$CITY" $LAT $LON > "$HOME/.dotfiles/bin/weather/.env.location"
            # emptying weather buffer
            >"$HOME/.dotfiles/bin/weather/.env.weather"
            ;;
        ?)
            usage
            ;;
    esac
done

