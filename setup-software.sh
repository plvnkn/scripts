#!/bin/bash

curl https://raw.githubusercontent.com/plvnkn/scripts/master/softwarelist.csv -O

sudo pacman --noconfirm -Syy git

git clone https://github.com/plvnkn/tools

cd tools/st
sudo make install
cd ~ 

#first install yay to be able to install aur packages#
cd tools
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --noconfirm -si
cd ~





while IFS=, read -r package type
do
	case "$type" in
			"") 
				sudo pacman --noconfirm --needed -Syy "$package" 
				;;
			"a") 
				yay --noconfirm -S "$program" 
				;;
	esac
done < softwarelist.csv

rm softwarelist.csv
