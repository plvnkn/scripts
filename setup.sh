#!/bin/bash

curl https://raw.githubusercontent.com/plvnkn/scripts/master/config/partition-layout-template --create-dirs -o config/partition-layout-template

#get total memory to calculate the SWAP size
boot="+200M"
root=$(inputBox "Root partition in GB" "Partitioning" "Root")
swap=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)

cat <<EOF | fdisk /dev/sda
o
n
p


$boot
n
p


+${root}G
n
p


+${swap}G
n
p


w
EOF



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

curl https://raw.githubusercontent.com/plvnkn/scripts/master/config/system-configuration.sh --create-dirs -o /mnt/root/system-configuration.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh --create-dirs -o /mnt/root/lib/dialog.functions.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/useradd.sh --create-dirs -o /mnt/root/useradd.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/setPasswd.sh --create-dirs -o /mnt/root/setPasswd.sh

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt sh ~/system-configuration.sh
umount /dev/sda1
