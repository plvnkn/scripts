#!/bin/bash

#first install yay to be able to install aur packages#
cd ~/tools
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd -

while IFS=, read -r package type
do
	case "$type" in
			"") 
				pacman -S "$package" 
				;;
			"a") 
				yay "$program" 
				;;
	esac
done < softwarelist.csv
