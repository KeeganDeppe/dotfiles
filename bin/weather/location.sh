#!/usr/bin/env bash
# sets enviroment variables on login
CURRENT_LOCATION=$(curl --silent http://ip-api.com/csv)
CITY=$(echo "$CURRENT_LOCATION" | cut -d , -f 6)
LAT=$(echo "$CURRENT_LOCATION" | cut -d , -f 8)
LON=$(echo "$CURRENT_LOCATION" | cut -d , -f 9)

export LAT LON CITY

