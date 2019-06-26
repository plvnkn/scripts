#!/bin/bash

. ~/lib/dialog.functions.sh

if [ -z $1 ]; then pwForUser="root"; else pwForUser="$1"; fi

#password
while true
do
	exec 3>&1
	
	passwd=$(pwBox "Password ($pwForUser)" "User Managment" "Password") 
	
	if [ -z $passwd ]; then
		message "The password can not be empty!"
		continue
	fi
	
	passwd_repeat=$(pwBox "Confirm Password ($pwForUser)" "User Managment" "Password") 
	
	if [ -z $passwd_repeat ]; then
		message "The confirmation password can not be empty!"
		continue
	fi
	
	if [ "$passwd" != "$passwd_repeat" ]; then
		message "The passwords are not identically!"
		continue
		else
			break
	fi
	
	exec 3>&-
done

echo "$pwForUser:$passwd" | chpasswd
