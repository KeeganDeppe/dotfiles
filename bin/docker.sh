#!/usr/bin/env bash
# Outputs information about the current docker status
EXISTS=$(which docker)
if [[ -z $EXISTS ]] ; then
    echo ""
else
    DOCKER_STATUS=$(docker info)
    CONTAINERS=$(echo "$DOCKER_STATUS" | awk '/Containers/ {print $2}')
    RUNNING=$(echo "$DOCKER_STATUS" | awk '/Running/ {print $2}')
    STOPPED=$(echo "$DOCKER_STATUS" | awk '/Stopped/ {print $2}')
    IMAGES=$(echo "$DOCKER_STATUS" | awk '/Images/ {print $2}')
    echo -e "\ue7b0 $RUNNING \ufb99 $STOPPED \uf1c5 $IMAGES"
fi
