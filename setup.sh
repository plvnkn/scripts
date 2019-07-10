#!/bin/bash
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh -O

. ./dialog.functions.sh


cat <<EOF | fdisk /dev/sda
n
p



w
EOF

password_dialog "Enter the password to encrypt your disk" "cryptPasswd"

cat <<EOF | cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 /dev/sda1
$cryptPasswd
EOF

cat <<EOF | cryptsetup luksOpen /dev/sda1 luks
$cryptPasswd
EOF

root=$(inputBox "Root partition size in GB" "Partitioning" "Root") 

swap=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)

#lvm
pvcreate /dev/mapper/luks
vgcreate vgcrypt /dev/mapper/luks
lvcreate -L ${root}G vgcrypt -n root
lvcreate -L ${swap}G vgcrypt -n swap
lvcreate -l 100%FREE vgcrypt -n home

mkfs.ext4 /dev/mapper/vgcrypt-root
mkfs.ext4 /dev/mapper/vgcrypt-home

mkswap /dev/mapper/vgcrypt-swap
swapon /dev/mapper/vgcrypt-swap

#creating and mount folders
mount /dev/mapper/vgcrypt-root /mnt
mkdir -p /mnt/home

mount /dev/mapper/vgcrypt-home /mnt/home

curl https://raw.githubusercontent.com/plvnkn/scripts/master/config/system-configuration.sh --create-dirs -o /mnt/root/system-configuration.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh --create-dirs -o /mnt/root/lib/dialog.functions.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/useradd.sh --create-dirs -o /mnt/root/useradd.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/setPasswd.sh --create-dirs -o /mnt/root/setPasswd.sh

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion grub vim
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt sh ~/system-configuration.sh
umount -R /mnt
