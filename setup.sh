#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/plvnkn/scripts/master/lib/dialog.functions.sh)

cat <<EOF | fdisk /dev/sda
n
p



w
EOF

clear
echo "--- Disc Encryption ---"

while true
do
	echo -n "Password: ";
	read -s passwd_encryption;
	
	if [ -z $passwd_encryption ]; then
		echo "The password can not be empty!\n"
		continue
	fi	
	
	echo -n
	echo -n "Repeat password: "
	read -s passwd_repeat;
	
	if [ -z $passwd_repeat ]; then
		echo "The confirmation password can not be empty!"
		continue
	fi
	
	if [ "$passwd_encryption" != "$passwd_repeat" ]; then
		echo "The passwords are not identically!"
		continue
		else
			printf -v $OPTION $passwd
			break
	fi
done

export passwd_encryption=${passwd_encryption}

cat <<EOF | cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 /dev/sda1
${passwd_encryption}
EOF

cat <<EOF | cryptsetup luksOpen /dev/sda1 luks
${passwd_encryption}
EOF

clear
echo -n "Enter the root partition size in GB"
read root;

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
curl https://raw.githubusercontent.com/plvnkn/scripts/master/usermanagement/useradd.sh --create-dirs -o /mnt/root/useradd.sh

chmod +x /mnt/root/*

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion grub vim
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt /root/system-configuration.sh "${passwd_encryption}"

arch-chroot /mnt /root/useradd.sh

echo " -- Root password --"
arch-chroot /mnt passwd

umount -R /mnt
