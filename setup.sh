#!/bin/bash

curl https://raw.githubusercontent.com/plvnkn/scripts/master/config/partition-layout-template --create-dirs -o config/partition-layout-template

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

curl https://raw.githubusercontent.com/plvnkn/scripts/master/configuration.sh --create-dirs -o /mnt/root/configuration.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh --create-dirs -o /mnt/root/lib/dialog.functions.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/useradd.sh --create-dirs -o /mnt/root/useruseradd.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/setPasswd.sh --create-dirs -o /mnt/root/setPasswd.sh

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion syslinux
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt sh ~/configuration.sh
