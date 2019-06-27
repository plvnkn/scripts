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

#groups
groups=$(inputBox "Groups" "User Management" "Useradd") 	

if [ -z $groups ]; then g=""; else g=$(echo "-G $groups"); fi
useradd -m -g users $g -s /bin/bash $user

sh setPasswd.sh $user
