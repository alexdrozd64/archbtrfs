#!/bin/bash

# Arch Linux Fast Install - Быстрая установка Arch Linux https://github.com/ordanax/arch
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).
# Автор скрипта Алексей Бойко https://vk.com/ordanax


loadkeys ru
setfont cyr-sun16
echo 'Скрипт сделан на основе чеклиста Бойко Алексея по Установке ArchLinux'
echo 'Ссылка на чек лист есть в группе vk.com/arch4u'

echo '2.3 Синхронизация системных часов'
timedatectl set-ntp true

echo '2.4 создание разделов'
(
 echo g;

 echo n;
 echo ;
 echo;
 echo +200M;
 #echo y;
 echo t;
 echo 1;

 echo n;
 echo;
 echo;
 echo +2G;
 #echo y;
 
  
 echo n;
 echo;
 echo;
 echo;
 #echo y;
  
 echo w;
) | fdisk /dev/sda

echo 'Ваша разметка диска'
fdisk -l
umount -R /mnt  # если возникает ошибка при монтировании в VBox
echo '2.4.2 Форматирование дисков'

mkfs.fat -F32 /dev/sda1
mkswap -L swap /dev/sda2
swapon /dev/sda2
mkfs.btrfs -f -L arch /dev/sda3

mount /dev/sda3 /mnt
#####создадим подтома под root и домашний каталог пользователя и для снапшотов:
btrfs subvolume create /mnt/arch_root
btrfs subvolume create /mnt/arch_home
btrfs subvolume create /mnt/arch_snapshots
btrfs subvolume create /mnt/arch_cache
umount /mnt 
mount -o noatime,compress=lzo,space_cache,subvol=arch_root /dev/sda3 /mnt
mkdir -p /mnt/{home,boot,boot/efi,var,var/cache,.snapshots}
mount -o noatime,compress=lzo,space_cache,subvol=arch_cache /dev/sda3 /mnt/var/cache
mount -o noatime,compress=lzo,space_cache,subvol=arch_home /dev/sda3 /mnt/home
mount -o noatime,compress=lzo,space_cache,subvol=arch_snapshots /dev/sda3 /mnt/.snapshots
mount /dev/sda1 /mnt/boot/efi
umount /mnt 


echo '3.1 Выбор зеркал для загрузки.'
rm -rf /etc/pacman.d/mirrorlist
wget https://git.io/mirrorlist
mv -f ~/mirrorlist /etc/pacman.d/mirrorlist

echo '3.2 Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl

echo '3.3 Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL git.io/archuefi2.sh)"
