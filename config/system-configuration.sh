#!/bin/bash
. ~/lib/dialog.functions.sh

#create a keyfile 
dd if=/dev/urandom of=/crypto_keyfile.bin bs=512 count=4

chmod 000 /crypto_keyfile.bin

cat <<EOF | cryptsetup luksAddKey /dev/sda1 /crypto_keyfile.bin
$1
EOF

#remove comments
sed '/^[[:blank:]]*#/d;s/#.*//' /etc/mkinitcpio.conf

sed -i '/^MODULES/c\MOUDULES="ext4"' /etc/mkinitcpio.conf
sed -i '/^HOOKS/c\HOOKS="base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck shutdown"' /etc/mkinitcpio.conf
sed -i '/^FILES/c\FILES=/crypto_keyfile.bin' /etc/mkinitcpio.conf
mkinitcpio -p linux

#confiuration
clear
echo -n "Enter the hostname for this machine and confirm with [ENTER]: "
read hostname
echo $hostname > /etc/hostname

PS3="Select the locale"
options=("en_US" "de_DE" "ru_RU" "other")
select opt in "${options[@]}"
do
    case $opt in
        "en_US")
			echo "LANG=en_US.UTF-8 "> /etc/locale.conf
            echo "Your locale is set to 'en_US.UTF-8'"
            break
            ;;
        "de_DE")
			echo "LANG=de_DE.UTF-8 "> /etc/locale.conf
            echo "Your locale is set to 'de_DE.UTF-8'"
            break
            ;;
        "ru_RU")
			echo "LANG=ru_RU.UTF-8 "> /etc/locale.conf
            echo "Your locale is set to 'ru_RU.UTF-8'"
            break
            ;;
        "other")
			echo -n "Enter the locale for this machine and confirm with [ENTER]: "
			read locale
			echo LANG=$locale.UTF-8 > /etc/hostname
			break
			;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

PS3="Slect the keymap"
options=("us" "de" "ru" "other")
select opt in "${options[@]}"
do
    case $opt in
        "us")
			echo "KEYMAP=us" > /etc/vconsole.conf
			echo "us" > /etc/locale.conf
            echo "Your keymap is set to 'us'"
            break
            ;;
        "de")
			echo "KEYMAP=de" > /etc/vconsole.conf
            echo "Your keymap is set to 'de'"
            break
            ;;
        "ru")
			echo "KEYMAP=ru" > /etc/vconsole.conf
            echo "Your keymap is set to 'ru'"
            break
            ;;
        "other")
			echo -n "Enter the keymap for this machine and confirm with [ENTER]: "
			read keymap
			echo KEYMAP=$keymap > /etc/vconsole.conf
			break
			;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

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
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
