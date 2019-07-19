#!/bin/bash

. ~/lib/dialog.functions.sh

if [ -z $1 ]; then pwForUser="root"; else pwForUser="$1"; fi

password_dialog "Password ($pwForUser)" "User"

cat <<EOF | passwd "pwForUser"
${passwd_User}
${passwd_User}
EOF
