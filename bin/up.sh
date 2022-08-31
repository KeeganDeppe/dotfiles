#!/usr/bin/env bash

uptime=$(cat /proc/uptime | awk '{print $1 / 60; print $1 % 60}' | xargs printf '%d min %d sec' 2>/dev/null)
echo "$uptime"
