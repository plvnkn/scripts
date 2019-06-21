#!/bin/bash

mkdir config
wget https://raw.githubusercontent.com/plvnkn/scripts/master/config/partition-layout-template -O config/partition-layout-template


#get total memory to calculate the SWAP size
SWAP_SIZE_GB=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)
SWAP_SIZE=$(echo "$SWAP_SIZE_GB * 1024*1024 *2" | bc)
HOME_START=$(echo "25372672+($SWAP_SIZE_GB * 1024*1024 *2)" | bc)
TOTAL_SECTORS=$(fdisk -l | awk 'NR==1{ print $7 }')
HOME_SIZE=$(echo "$TOTAL_SECTORS - $HOME_START" | bc)


#replace placeholders in partition layout template
sed -e "s/\${SWAP_SIZE}/$SWAP_SIZE/" \
	-e "s/\${HOME_START}/$HOME_START/" \
	-e "s/\${HOME_SIZE}/$HOME_SIZE/" \
	config/partition-layout-template > partition-config

sfdisk /dev/sda < partition-config
rm partition-config

mkfs.ext4 -L BOOT /dev/sda1
mkfs.ext4 -L ROOT /dev/sda2
mkfs.ext4 -L HOOT /dev/sda4
mkswap -L SWAP /dev/sda3
swapon /dev/sda3

#creating and mount folders
mount /dev/sda2 /mnt
mkdir -p /mnt/home
mkdir -p /mnt/boot

mount /dev/sda4 /mnt/home
mount /dev/sda1	/mnt/boot

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion
echo "genfstab -Up /mnt > /mnt/etc/fstab"
genfstab -Up /mnt > /mnt/etc/fstab

echo "arch-chroot /mnt";
arch-chroot /mnt

#confiuration
read -p 'Hostname: ' HOST_NAME
echo $HOST_NAME > /etc/hostname

lang=$(dialog --clear --title "LANG" --no-tags --menu "Select your locale" 60 10 60 $(ls /usr/share/i18n/locales) 3>&1 1>&2 2>&3 3>&-)
echo LANG=$lang.UTF-8 > /etc/locale.conf 

keymap=$(dialog --clear --title "KEYMAP" --no-tags --menu "Select your keyboard mapping" 60 10 60 $(localectl list-keymaps) 3>&1 1>&2 2>&3 3>&-)
echo KEYMAP=$keymap > /etc/vconsole.conf

zone1=$(cd ..dialog --clear --title "ZONE" --no-tags --menu "Select your continent" 60 10 60 $(ls -l /usr/share/zoneinfo/ | grep '^d') 3>&1 1>&2 2>&3 3>&-)
zone2=$(cd ..dialog --clear --title "ZONE" --no-tags --menu "Select your area" 60 10 60 $(ls -l /usr/share/zoneinfo/$zone1) 3>&1 1>&2 2>&3 3>&-)
ln -sf /usr/share/zoneinfo/$zone1/$zone2 /etc/localtime
