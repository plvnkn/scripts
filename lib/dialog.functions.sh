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
	exec 3>&1
	dialog \
		--clear \
		--backtitle "$2" \
		--title "$3" \
		--insecure \
		--passwordbox "$1" \
		7 70 2>&1 1>&3
	exec 3>&-
}
