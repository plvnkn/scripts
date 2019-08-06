#!/bin/bash

#first install yay to be able to install aur packages#
cd ~/tools
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~

while IFS=, read -r package type
do
	case "$type" in
			"") 
				pacman --no-confirm --needed -Syy "$package" 
				;;
			"a") 
				yay --no-confirm -S "$program" 
				;;
	esac
done < softwarelist.csv
