#!/bin/bash
# install dependencies

sudo apt install git x11proto-dev libx11-dev libxft-dev

#install suckless terminal

mkdir ~/tools
cd tools
git clone https://git.suckless.org/st
cd st && sudo make install
