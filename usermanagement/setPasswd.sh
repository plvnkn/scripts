#!/bin/bash

. ~/lib/dialog.functions.sh

if [ -z $1 ]; then pwForUser="root"; else pwForUser="$1"; fi

password_dialog "Password ($pwForUser)" "User"

echo -e "$passwd_User\n$passwd_User" | passwd "$pwForUser"
