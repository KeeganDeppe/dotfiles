#!/usr/bin/env bash
# makes sure agent is active and adds keys
if [ -z $SSH_AGENT_SOCK ] ; then
    # agent unset
    eval $(ssh-agent -s)
    if [ "$(ssh-add -l)" = "The agent has no identities." ] ; then
        if [ -e ~/.ssh/id_ed25519 ] ; then
            ssh-add ~/.ssh/id_ed25519
        else
            kill $SSH_AGENT_PID
            echo -e "No ed25519 keys found! Killing $SSH_AGENT_PID!"
        fi
    else
        kill $SSH_AGENT_PID
        echo "Killing $SSH_AGENT_PID!"
    fi
fi

