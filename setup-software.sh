#!/bin/bash

sudo pacman --noconfirm -Syy git

#first install yay to be able to install aur packages#
mkdir tools
cd tools
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd -

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
