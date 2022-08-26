#!/usr/bin/env bash

# constants
timeout=120 # in seconds
refresh_rate=10 # display each station for 10 seconds
WORKINGDIR="$HOME/.dotfiles/bin/bluebikes"

if [[ ! -d "$WORKINGDIR/data" ]] ; then
    mkdir -p "$WORKINGDIR/data"
fi

# getting time and existing information
TIME=$(date +%s)
OLD_EXPIRATION=$(ls "$WORKINGDIR/data" | cut -d '.' -f 1 2>/dev/null) # removes .json extension

get_station_info() {
    # cleans data folder and leaves only most recent copy
    rm "$WORKINGDIR/data/"*.json 2>/dev/null
    BB_STATUS=$(curl --silent -fL https://gbfs.bluebikes.com/gbfs/en/station_status.json)
    EXPIRATION=$(($TIME + 120)) # sets expiration to be in 120 seconds
    echo "$BB_STATUS" > "$WORKINGDIR/data/$EXPIRATION.json"
    #echo $EXPIRATION
}

update_stations() {
    # checks to see if we are out of date and sets $output to be station info
    if [[ -z $OLD_EXPIRATION || $OLD_EXPIRATION -lt $EXPIRATION ]] ; then
        # file doesn't exist or is more than a minute old
        get_station_info
    fi

    STATIONS=$(cat "$WORKINGDIR/conf.json" | gojq '.stations') # stations we care about from config file
    STATION_INFO=$(cat "$WORKINGDIR/"data/*.json 2>/dev/null) # all station information

    # all associated data for the specific ids
    info=$(echo "$STATION_INFO" | gojq --argjson js "$STATIONS" '[.data.stations[] | select( .station_id as $id | $js.[].station_id | tostring | . == $id )]')
    # only available bikes/docks for the required ids
    output=$(echo "$info" | gojq --argjson names "$STATIONS" '[ .[] | .station_id as $id | { bikes: .num_bikes_available, docks: .num_docks_available, station: $names.[] | select( .station_id | tostring | . == $id ) | .name }]')
    
#    echo "$output"
}


output_status() {
    # reads $OUTPUT and the Index value
    minute=$(date +%M | tr -d '0')
    tot=$(echo "$STATIONS" | gojq '. | length') # display one per minute
    index=$(( $minute % $tot ))
    bikes=$(echo "$output" | gojq --arg indx $index '.[$indx | tonumber ].bikes')
    docks=$(echo "$output" | gojq --arg indx $index '.[$indx | tonumber ].docks')
    station=$(echo "$output" | gojq --arg indx $index '.[$indx | tonumber ].station' | tr -d '"')
    printf '%d   %d   %s' "$docks" "$bikes" "$station"
}

update_stations # sets $output to be all the stations we are interested in
output_status # echos correct station info based on index and time

