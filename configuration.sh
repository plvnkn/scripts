#!/bin/bash
#confiuration
read -p 'Hostname: ' HOST_NAME
echo $HOST_NAME > /etc/hostname

lang=$(dialog --clear --title "LANG" --no-tags --menu "Select your locale" 60 10 60 $(ls /usr/share/i18n/locales) 3>&1 1>&2 2>&3 3>&-)
echo LANG=$lang.UTF-8 > /etc/locale.conf 

keymap=$(dialog --clear --title "KEYMAP" --no-tags --menu "Select your keyboard mapping" 60 10 60 $(localectl list-keymaps) 3>&1 1>&2 2>&3 3>&-)
echo KEYMAP=$keymap > /etc/vconsole.conf

exec 3>&1
zone1=$(dialog --clear --title "ZONE" --no-tags --menu "Select your continent" 60 10 60 $(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }' | awk '{ print NR" "$0 }') 2>&1 1>&3 3>&-)
continent=$(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }' | sed -n ${zone1}p)

zone2=$(dialog --clear --title "ZONE" --no-tags --menu "Select your area" 60 10 60 $(ls /usr/share/zoneinfo/$continent | awk '{ print NR" "$0 }') 2>&1 1>&3 3>&-)
area=$(ls /usr/share/zoneinfo/$continent | sed -n ${zone2}p)

ln -sf /usr/share/zoneinfo/$continent/$area /etc/localtime

echo $lang.UTF-8 >> /etc/locale.gen

echo  '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

blkid /dev/sda2 | awk '{ print $3 }' | awk -F '"' '$0=$2'

pacman -S networkmanager grub
systemctl enable NetworkManager

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

read -p 'Username: ' $USER_NAME

x=0
while [ x == 0 ]
do
	read -s -p 'Password: ' USER_PASSWD
	read -s -p 'Repeat Password: ' USER_REPEAT_PASSWD
	if [$USER_PASSWD != USER_REPEAT_PASSWD]
		echo 'Passwords are not identical'
	fi
	x=1
done

useradd -m -g users -G wheel,audio,video -s /bin/bash $USER_NAME
echo $USER_PASSWD | passwd $USER_NAME --stdin

x=0
while [ x == 0 ]
do
	read -s -p 'Password(Admin): ' ADMIN_PASSWD
	read -s -p 'Repeat Password(Admin): ' ADMIN_REPEAT_PASSWD
	if [$ADMIN_PASSWD != ADMIN_REPEAT_PASSWD]
		echo 'Passwords are not identical'
	fi
	x=1
done
echo $ADMIN_PASSWD | passwd --stdin

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers


