#!/bin/bash

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
