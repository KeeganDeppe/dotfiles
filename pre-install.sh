#!/bin/bash

OMZDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
	echo "Installing oh-my-zsh"
	/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
	echo "Consider updating oh-my-zsh using: omz update"
fi

if [ -n "$ZSH_NAME" ]; then
	echo "Changing default shell to zsh"
	chsh -s /bin/zsh 
else
	echo "zsh already enabled"
fi

