#!/bin/bash
#confiuration
read -p 'Hostname: ' HOST_NAME
echo $HOST_NAME > /etc/hostname

lang=$(dialog --clear --title "LANG" --no-tags --menu "Select your locale" 60 10 60 $(ls /usr/share/i18n/locales) 3>&1 1>&2 2>&3 3>&-)
echo LANG=$lang.UTF-8 > /etc/locale.conf 

keymap=$(dialog --clear --title "KEYMAP" --no-tags --menu "Select your keyboard mapping" 60 10 60 $(localectl list-keymaps) 3>&1 1>&2 2>&3 3>&-)
echo KEYMAP=$keymap > /etc/vconsole.conf

zone1=$(dialog --clear --title "ZONE" --no-tags --menu "Select your continent" 60 10 60 $(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }') 3>&1 1>&2 2>&3 3>&-)
zone2=$(dialog --clear --title "ZONE" --no-tags --menu "Select your area" 60 10 60 $(ls -l /usr/share/zoneinfo/$zone1) 3>&1 1>&2 2>&3 3>&-)
ln -sf /usr/share/zoneinfo/$zone1/$zone2 /etc/localtime
