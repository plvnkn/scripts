#!/bin/bash

. ~/lib/dialog.functions.sh

if [ -z $1 ]; then pwForUser="root"; else pwForUser="$1"; fi

password_dialog "Password ($pwForUser)" "User"

echo -e $(esc "$passwd_User")\"\\n\"$(esc "$passwd_User") | passwd "$pwForUser"
