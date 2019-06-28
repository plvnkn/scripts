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
	dialog --no-cancel --inputbox "$1" --backtitle "$2" --title "$3" 10 60
}

# useage: message "Password" "backtitle" "title"
pwBox() {
	dialog --no-cancel  --backtitle "$2" --title "$3" --insecure --passwordbox "$1" 10 60
}
