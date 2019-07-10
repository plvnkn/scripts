#!/bin/bash
#Library for reusable functions

# useage: message "This is a message"
message(){
	dialog  \
		--clear \
		--backtitle "$backtitle" --no-collapse --cr-wrap \
		--msgbox "$1" 5 70	
}

# useage: message "Username" "backtitle" "title" "default"
inputBox() {	
	dialog \
		--clear \
		--backtitle "$2" \
		--title "$3" \
		--inputbox "$1" \
		7 70 3>&1 1>&2 2>&3 3>&-
}



# useage: message "Password" "backtitle" "title"
pwBox() {
	dialog \
		--clear \
		--insecure \
		--no-cancel \
		--passwordbox "$1" \
		7 70 3>&1 1>&2 2>&3 3>&-
}

password_dialog() {
while true
do
	passwd=$(pwBox "$1")
	if [ -z $passwd ]; then
		message "The password can not be empty!"
		continue
	fi
	
	passwd_repeat=$(pwBox "Confirm Password")
	
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
done
}
