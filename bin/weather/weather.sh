#!/bin/bash

# if you get my email banned ill freak out
API_KEY='60844f78595f66ff8e94df50aed24397'

LOCATION=$(curl --silent http://ip-api.com/csv)
CITY=$(echo "$LOCATION" | cut -d , -f 6)
LAT=$(echo "$LOCATION" | cut -d , -f 8)
LON=$(echo "$LOCATION" | cut -d , -f 9)
# getting weather
WEATHER=$(curl --silent http://api.openweathermap.org/data/2.5/weather\?lat="$LAT"\&lon="$LON"\&appid="$API_KEY"\&units=imperial)
echo $WEATHER
