#!/bin/bash
. ~/lib/dialog.functions.sh

#username
while true
do
	user=$(inputBox "Username" "User Management" "Useradd") 
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

echo " -- Password for user $user --"
passwd $user
