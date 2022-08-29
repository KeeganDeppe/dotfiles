#!/bin/bash
set -e

cd $HOME/.dotfiles/tmux/plugins/tmux-mem-cpu-load
cmake .
make
sudo make install
