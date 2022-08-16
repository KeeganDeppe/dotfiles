#!/usr/bin/env bash
# makes sure agent is active and adds keys
if [ -z $SSH_AUTH_SOCK ] ; then
    # agent unset
    eval $(ssh-agent -s)
    if [ "$(ssh-add -l)" = "The agent has no identities." ] ; then
        if [ -e ~/.ssh/id_ed25519 ] ; then
            ssh-add ~/.ssh/id_ed25519
        else
            echo -e "No ed25519 keys found! Killing $SSH_AGENT_PID!"
            eval $(ssh-agent -k)
        fi
    else
        echo "Killing $SSH_AGENT_PID!"
        eval $(ssh-agent -k)
    fi
else
    echo "Agent already running at $SSH_AGENT_PID!"
fi
