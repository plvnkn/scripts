#!/bin/bash
yellow=$(tput setaf 3)
normal=$(tput sgr0)

#create a keyfile 
dd if=/dev/urandom of=/crypto_keyfile.bin bs=512 count=4

chmod 000 /crypto_keyfile.bin
part=$(lsblk $2 -pl | grep part | awk '{ print $1 }')
cat <<EOF | cryptsetup luksAddKey $part /crypto_keyfile.bin
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
printf "${yellow}Hostname: ${normal}"
read hostname
echo $hostname > /etc/hostname

printf "\n"
PS3="${yellow}Select the locale${normal}: "
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
			echo LANG=$locale.UTF-8 > /etc/locale.conf
			break
			;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

printf "\n"
PS3="${yellow}Select the keymap${normal}: "
options=("us" "de" "ru" "other")
select opt in "${options[@]}"
do
    case $opt in
        "us")
			echo "KEYMAP=us" > /etc/vconsole.conf
            echo "Your keymap is set to 'us'"
            break
            ;;
        "de")
			echo "KEYMAP=de-latin1-nodeadkeys" > /etc/vconsole.conf
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


cd /usr/share/zoneinfo
area=$(ls -d */ | grep -v "Etc/\|posix/\|right/\|SystemV/" | cut -f1 -d'/')
printf "\n"
PS3="${yellow}Select your timezone:{normal} "
select area1 in $area
do
    case $area1 in
        *) echo "You have chosen $area1"
        break
        ;;
    esac
done
cd -

printf "\n"
PS3="Select your area: "
select area2 in $(ls /usr/share/zoneinfo/$area1)
do
    case $area2 in
        *) echo "You have chosen $area2"
        break
        ;;
    esac
done

ln -sf /usr/share/zoneinfo/$area1/$area2 /etc/localtime

echo $lang.UTF-8 >> /etc/locale.gen
echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

yes | pacman -Sy networkmanager grub
systemctl enable NetworkManager

sed -i '/^GRUB_CMDLINE_LINUX/c\GRUB_CMDLINE_LINUX="cryptdevice=UUID=%uuid%:luks"' /etc/default/grub
sed -i s/%uuid%/$(blkid -o value -s UUID $part)/ /etc/default/grub

sed -i '/GRUB_ENABLE_CRYPTODISK/c\GRUB_ENABLE_CRYPTODISK=y' /etc/default/grub
grub-install "$2"
grub-mkconfig -o /boot/grub/grub.cfg

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

printf "\n${yellow}Adding a new user${normal}"
while true
	do
		printf "\nEnter a username and confirm with [ENTER]: "
		read user
		if [ -z $user ]; then
			message "The username can not be empty!"
			continue
		fi
		
		if id -u $user > /dev/null 2>&1; then
			message "This username '$user' is already in use!"
			else 
			break
		fi
done

useradd -m -g users -G wheel,video,audio -s /bin/bash $user
printf " \n${yellow}Password for user $user{normal}\n"
passwd $user
