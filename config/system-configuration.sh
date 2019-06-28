#!/bin/bash
. ~/lib/dialog.functions.sh

#confiuration
dialog --no-cancel --inputbox "Hostname" 10 60 2> hostname
echo $hostname > /etc/hostname

dialog --clear --title "LANG" --no-tags --menu "Select your locale" 60 50 60 $(ls /usr/share/i18n/locales | awk '{ print NR" "$0 }' ) 2>lang
echo LANG=$lang.UTF-8 > /etc/locale.conf 

dialog --clear --title "Keymap settings" --no-tags --menu "Select your keyboard mapping" 60 50 60 $(localectl list-keymaps) 2> keymap
echo KEYMAP=$keymap > /etc/vconsole.conf

dialog --clear --title "Time zone" --no-tags --menu "Select your continent" 60 50 60 $(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }' | awk '{ print NR" "$0 }') 2>zone1
continent=$(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }' | sed -n ${zone1}p)

dialog --clear --title "ZONE" --no-tags --menu "Select your area" 60 50 60 $(ls /usr/share/zoneinfo/$continent | awk '{ print NR" "$0 }')2> zone2
area=$(ls /usr/share/zoneinfo/$continent | sed -n ${zone2}p)

ln -sf /usr/share/zoneinfo/$continent/$area /etc/localtime

echo $lang.UTF-8 >> /etc/locale.gen

echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

blkid /dev/sda2 | awk '{ print $3 }' | awk -F '"' '$0=$2'

yes | pacman -Sy networkmanager grub
systemctl enable NetworkManager

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

sh ~/useradd.sh
sh ~/setPasswd.sh

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
