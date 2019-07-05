#!/bin/bash
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh -O

. ./dialog.functions.sh


cat <<EOF | fdisk /dev/sda
n
p



w
EOF

cat <<EOF | cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 /dev/sda1
passwd
EOF

cat <<EOF | cryptsetup luksOpen /dev/sda1 cr_crypto
passwd
EOF

#get total memory to calculate the SWAP size

#dialog --no-cancel --inputbox "Root partition size in GB" 10 60 2> root

root=$(inputBox "Root partition size in GB" "Partitioning" "Root") 

swap=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)

#lvm
pvcreate /dev/mapper/cr_crypto
vgcreate main /dev/mapper/cr_crypto
lvcreate -L ${root}G main -n root
lvcreate -L ${swap}G main -n swap
lvcreate -l 100%FREE main -n home

mkfs.ext4 /dev/mapper/main-root
mkfs.ext4 /dev/mapper/main-home

mkswap /dev/mapper/main-swap
swapon /dev/mapper/main-swap

#creating and mount folders
mount /dev/mapper/main-root /mnt
mkdir -p /mnt/home

mount /dev/mapper/main-home /mnt/home

curl https://raw.githubusercontent.com/plvnkn/scripts/master/config/system-configuration.sh --create-dirs -o /mnt/root/system-configuration.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh --create-dirs -o /mnt/root/lib/dialog.functions.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/useradd.sh --create-dirs -o /mnt/root/useradd.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/setPasswd.sh --create-dirs -o /mnt/root/setPasswd.sh

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion grub vim
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt sh ~/system-configuration.sh
umount -R /mnt
