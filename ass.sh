#!/bin/bash
yellow=$(tput setaf 3)
normal=$(tput sgr0)

printf "\n${yellow}    #${normal}"                                                       
printf "\n${yellow}   # #${normal}   #####   ####  #    # #      # #    # #    # #    #" 
printf "\n${yellow}  #   #${normal}  #    # #    # #    # #      # ##   # #    #  #  #"  
printf "\n${yellow} #     #${normal} #    # #      ###### #      # # #  # #    #   ##"   
printf "\n${yellow} #######${normal} #####  #      #    # #      # #  # # #    #   ##"   
printf "\n${yellow} #     #${normal} #   #  #    # #    # #      # #   ## #    #  #  #"  
printf "\n${yellow} #     #${normal} #    #  ####  #    # ###### # #    #  ####  #    #" 
printf "\n"                                                            
printf "\n${yellow}  #####${normal}"                                                     
printf "\n${yellow} #     #${normal} #####  ###### ###### #####"                         
printf "\n${yellow} #      ${normal} #    # #      #      #    #"                        
printf "\n${yellow}  #####${normal}  #    # #####  #####  #    #"                        
printf "\n${yellow}       #${normal} #####  #      #      #    #"                        
printf "\n${yellow} #     #${normal} #      #      #      #    #"                        
printf "\n${yellow}  #####${normal}  #      ###### ###### #####"                         
printf "\n"                                                            
printf "\n${yellow}  #####${normal}"                                                     
printf "\n${yellow} #     #${normal} ###### ##### #    # #####"                          
printf "\n${yellow} #      ${normal} #        #   #    # #    #"                         
printf "\n${yellow}  #####${normal}  #####    #   #    # #    #"                         
printf "\n${yellow}       #${normal} #        #   #    # #####"                          
printf "\n${yellow} #     #${normal} #        #   #    # #"                              
printf "\n${yellow}  #####${normal}  ######   #    ####  #\n\n"
                    
                    
read -n 1 -s -r -p "Press any key to continue"
clear                     
printf "Preparing disc for install"

cat <<EOF | fdisk /dev/sda
n
p



w
EOF

printf "disc preparation done"

printf "\n${yellow}--- Disc Encryption --- ${normal}"

while true
do
	printf "\nPassword: "
	read -s passwd_encryption;
	
	if [ -z $passwd_encryption ]; then
		printf "\nThe password can not be empty!"
		continue
	fi	
	
	printf "\nRepeat password: "
	read -s passwd_repeat;
	
	if [ -z $passwd_repeat ]; then
		printf "\nThe confirmation password can not be empty!"
		continue
	fi
	
	if [ "$passwd_encryption" != "$passwd_repeat" ]; then
		printf "\nThe passwords are not identically!"
		continue
		else
			break
	fi
done

export passwd_encryption=${passwd_encryption}

printf "\nEncrypting disc..."

cat <<EOF | cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 /dev/sda1
${passwd_encryption}
EOF

cat <<EOF | cryptsetup luksOpen /dev/sda1 luks
${passwd_encryption}
EOF

printf "\nDisc encryption done"

printf "\n${yellow}Enter the root partition size in GB: ${normal}"
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

curl https://raw.githubusercontent.com/plvnkn/scripts/master/setup-system.sh --create-dirs -o /mnt/root/setup-system.sh

chmod +x /mnt/root/*

#install arch
pacstrap /mnt base base-devel wpa_supplicant dialog bash-completion grub neuvim
genfstab -Up /mnt > /mnt/etc/fstab
arch-chroot /mnt /root/setup-system.sh "${passwd_encryption}"

echo "${yellow}--- Root password ---${normal}"
arch-chroot /mnt passwd

umount -R /mnt
