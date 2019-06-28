#!/bin/bash


cat <<EOF | fdisk /dev/sda
n
p


w
EOF

cat <<EOF cryptsetup -q luksFormat -c aes-xts-plain64 -s 512 /dev/sda1
passwd
EOF

cat <<EOF cryptsetup luksOpen /dev/sda1 disk
passwd
EOF

pvcreate /dev/mapper/root
vgcreate vol /dev/mapper/root


#get total memory to calculate the SWAP size

dialog --no-cancel --inputbox "Root partition size in GB" --backtitle "Partitioning" --title "Root" 10 60 2>root

swap=$(awk '/MemTotal/ { print int(($2/1000/1000)+0.5) }' /proc/meminfo)

#lvm
pvcreate /dev/sda
vgcreate main /dev/sda
lvcreate -L ${root}G root -n /dev/sda
lvcreate -L ${swap} swap -n /dev/sda
lvcreate -l 100%FREE  home -n /dev/sda

mkfs.ext4 -L ROOT /dev/main/root
mkfs.ext4 -L HOOT /dev/main/home
mkswap -L SWAP /dev/main/swap
swapon /dev/main/swap


#creating and mount folders
mount /dev/main/root /mnt
mkdir -p /mnt/home
mkdir -p /mnt/boot

mount /dev/main/home /mnt/home
mount /dev/main/boot /mnt/boot

curl https://raw.githubusercontent.com/plvnkn/scripts/master/config/system-configuration.sh --create-dirs -o /mnt/root/system-configuration.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh --create-dirs -o /mnt/root/lib/dialog.functions.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/useradd.sh --create-dirs -o /mnt/root/useradd.sh
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/setPasswd.sh --create-dirs -o /mnt/root/setPasswd.sh

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion grub vim
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt sh ~/system-configuration.sh
umount /dev/sda1
