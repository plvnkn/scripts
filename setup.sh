#!/bin/bash

#partitioning
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +100M # 100 MB boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +16G # default, extend partition to end of disk
  n
  p
  3
	#
  +16G
  n
  p
  4
	#
    #   		
  w # write the partition table
  q # and we're done
EOF




# install dependencies

#sudo apt install git x11proto-dev libx11-dev libxft-dev

#install suckless terminal

#mkdir ~/tools
#cd tools
#git clone https://git.suckless.org/st
#cd st && sudo make install
