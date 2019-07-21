#!/bin/bash
clear

while true
do
	if [ -z $1 ]; then pwForUser="root"; else pwForUser="$1"; fi
	
	echo "Unter the passowrd for $pwForUser"

	echo -n "Password: "
	read -s password
	echo

		if [ -z $password ]; then
			echo "The password cannot be empty"
			continue
		fi

	echo -n "Repeat Password: "
	read -s password_confirm
	echo 

	if [ "$password" != "$password_confirm" ]; then
		echo "Passwords did not match" 
		continue  
	fi
	break
done

echo "$pwForUser:$password" | chpasswd --root /mnt
