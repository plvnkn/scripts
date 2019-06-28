#!/bin/bash
. ~/lib/dialog.functions.sh

#username
while true
do
	inputBox 2>user
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

sh ~/setPasswd.sh $user
