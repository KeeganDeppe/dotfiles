#!/usr/bin/env bash
# checks for agent status and echos to status bar

SOCK=$(readlink -f ~/.ssh/ssh_auth_sock)

if [ -e $SOCK ] ; then
    # agent active
    clr='#[fg=color34]' # green
    symb=$(echo -e '\uf00c')
else
    # agent not active
    clr='#[fg=color1]' # red
    symb=$(echo -e '\uf00d')
fi

printf 'Agent %s%s #[default]' $clr $symb
