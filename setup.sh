#!/bin/bash

mkdir config
wget https://raw.githubusercontent.com/plvnkn/scripts/master/config/partition-layout-template -O config/partition-layout-template


#get total memory to calculate the SWAP size
SWAP_SIZE_GB=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)
SWAP_SIZE=$(echo "$SWAP_SIZE_GB * 1024*1024 *2" | bc)
HOME_START=$(echo "25372672+($SWAP_SIZE_GB * 1024*1024 *2)" | bc)
TOTAL_SECTORS=$(fdisk -l | awk 'NR==1{ print $7 }')
HOME_SIZE=$(echo "$TOTAL_SECTORS - $HOME_START" | bc)


#replace placeholders in partition layout template
sed -e "s/\${SWAP_SIZE}/$SWAP_SIZE/" \
	-e "s/\${HOME_START}/$HOME_START/" \
	-e "s/\${HOME_SIZE}/$HOME_SIZE/" \
	config/partition-layout-template > partition-config

sfdisk /dev/sda < partition-config

# install dependencies

#sudo apt install git x11proto-dev libx11-dev libxft-dev

#install suckless terminal

#mkdir ~/tools
#cd tools
#git clone https://git.suckless.org/st
#cd st && sudo make install
