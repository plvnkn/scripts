#!/bin/bash

#get total memory to calculate the SWAP size
SWAP_SIZE=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)
echo $SWAP_SIZE
HOME_START=$(echo "25372672+$SWAP_SIZE" | bc)

TOTAL_SECTORS=$(fdisk -l | awk 'NR==1{ print $7 }')
HOME_SIZE=$(echo "$TOTAL_SECTORS - $HOME_START" | bc)

echo $HOME_SIZE

# install dependencies

#sudo apt install git x11proto-dev libx11-dev libxft-dev

#install suckless terminal

#mkdir ~/tools
#cd tools
#git clone https://git.suckless.org/st
#cd st && sudo make install
