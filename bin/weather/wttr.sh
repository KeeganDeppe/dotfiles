#!/usr/bin/env bash

HOUR=$(timedatectl | grep Local | cut -d ':' -f 2 | cut -d ' ' -f 4 | cut -d ':' -f 1)
if [[ ${HOUR} -gt 21 || ${HOUR} -lt 5 ]] ; then # between 9 pm and 5 am
    TIME_OF_DAY="NIGHT"
else
    TIME_OF_DAY="DAY"
fi
URL=$(printf 'https://v2%s.wttr.in?0&format=j1&nonce=$RANDOM' $TOD)
WTTR=$(curl --silent -fL $URL)
TMP=$(echo $WTTR | jq -r '.current_condition[0]')
TEMP=$(echo $TMP | jq -r '.temp_F')
HUMIDITY=$(echo $TMP | jq -r '.humidity')
CONDITIONS=$(echo $TMP | jq -r '.weatherDesc[0].value')
echo $TEMP $HUMIDITY $CONDITIONS
