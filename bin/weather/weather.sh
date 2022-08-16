#!/bin/bash

# if you get my email banned ill freak out
API_KEY='60844f78595f66ff8e94df50aed24397'
# getting weather
WEATHER=$(curl --silent http://api.openweathermap.org/data/2.5/weather\?lat="$LAT"\&lon="$LON"\&appid="$API_KEY"\&units=imperial)
echo $WEATHER
