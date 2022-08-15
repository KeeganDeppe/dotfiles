#!/bin/bash

mkdir -p $HOME/.local/share/fonts/hack
cd $HOME/.local/share/fonts/hack
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
unzip Hack.zip
rm -rf Hack.zip
mv 'Hack Regular Nerd Font Complete.ttf' $HOME/.local/share/fonts
mv 'Hack Regular Nerd Font Complete Mono.ttf' $HOME/.local/share/fonts
rm -rf $HOME/.local/share/fonts/hack
