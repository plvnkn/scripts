#!/bin/bash
. ~/lib/dialog.functions.sh

#create a keyfile 
dd if=/dev/urandom of=/crypto_keyfile.bin bs=512 count=4

chmod 000 /crypto_keyfile.bin

cat <<EOF  cryptsetup luksAddKey /dev/sda1 /crypto_keyfile.bin
$passwd
EOF

#remove comments
sed '/^[[:blank:]]*#/d;s/#.*//' /etc/mkinitcpio.conf

sed -i '/^MODULES/c\MOUDULES="ext4"' /etc/mkinitcpio.conf
sed -i '/^HOOKS/c\HOOKS="base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck shutdown"' /etc/mkinitcpio.conf
sed -i '/^FILES/c\FILES=/crypto_keyfile.bin' /etc/mkinitcpio.conf
mkinitcpio -p linux

#confiuration
hostname=$(inputBox "Hostname" "Systen Configuration" "Hostname")
echo $hostname > /etc/hostname

lang=$(dialog --clear --title "LANG" --no-tags --menu "Select your locale" 60 50 60 $(ls /usr/share/i18n/locales | awk '{ print NR" "$0 }' ) 3>&1 1>&2 2>&3 3>&-)
echo LANG=$lang.UTF-8 > /etc/locale.conf 

keymap=$(dialog --clear --title "KEYMAP" --no-tags --menu "Select your keyboard mapping" 60 50 60 $(localectl list-keymaps) 3>&1 1>&2 2>&3 3>&-)
echo KEYMAP=$keymap > /etc/vconsole.conf

zone1=$(dialog --clear --title "ZONE" --no-tags --menu "Select your continent" 60 50 60 $(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }' | awk '{ print NR" "$0 }') 3>&1 1>&2 2>&3 3>&-)
continent=$(ls -l /usr/share/zoneinfo | grep '^d' | awk '{ print $9 }' | sed -n ${zone1}p)

zone2=$(dialog --clear --title "ZONE" --no-tags --menu "Select your area" 60 50 60 $(ls /usr/share/zoneinfo/$continent | awk '{ print NR" "$0 }') 3>&1 1>&2 2>&3 3>&-)
area=$(ls /usr/share/zoneinfo/$continent | sed -n ${zone2}p)

ln -sf /usr/share/zoneinfo/$continent/$area /etc/localtime

echo $lang.UTF-8 >> /etc/locale.gen

echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

blkid /dev/sda2 | awk '{ print $3 }' | awk -F '"' '$0=$2'

yes | pacman -Sy networkmanager grub
systemctl enable NetworkManager

sed -i '/^GRUB_CMDLINE_LINUX/c\GRUB_CMDLINE_LINUX="cryptdevice=UUID=%uuid%:luks"' /etc/default/grub
sed -i s/%uuid%/$(blkid -o value -s UUID /dev/sda1)/ /etc/default/grub

sed -i '/GRUB_ENABLE_CRYPTODISK/c\GRUB_ENABLE_CRYPTODISK=y' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sda

sh ~/useradd.sh
sh ~/setPasswd.sh

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
