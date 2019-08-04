#!/bin/bash
clear
printf "Adding a new user"
while true
	do

		printf "\nEnter a username and confirm with [ENTER]: "
		read user

		if [ -z $user ]; then
			message "The username can not be empty!"
			continue
		fi
		
		if id -u $user > /dev/null 2>&1; then
			message "This username '$user' is already in use!"
			else 
				break
		fi
	done

useradd -m -g users -G wheel,video,audio -s /bin/bash $user

printf "Password for user $user\n:"
passwd $user

