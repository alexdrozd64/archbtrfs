#!/usr/bin/env bash

# Arch Linux Fast Install - Быстрая установка Arch Linux https://github.com/ordanax/arch
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).
# Автор скрипта Алексей Бойко https://vk.com/ordanax

# Прием переменных из первого скрипта
install_all=$1
boot=$install_all
swap=$2
root=$3

_install_all (){
  echo 'создание разделов'
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
  echo 'Форматирование дисков'
  echo
  mkfs.fat -F32 /dev/sda1
  mkswap -L swap /dev/sda2
  swapon /dev/sda2
  mkfs.btrfs -f -L arch /dev/sda3

  mount /dev/sda3 /mnt
  #####создадим подтома под root и домашний каталог пользователя и для снапшотов:
  btrfs subvolume create /mnt/@root
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@snapshots
  btrfs subvolume create /mnt/@cache
  umount /mnt
  mount -o noatime,compress=lzo,space_cache,subvol=@root /dev/sda3 /mnt
  mkdir -p /mnt/{home,boot,boot/efi,var,var/cache,.snapshots}
  mount -o noatime,compress=lzo,space_cache,subvol=@cache /dev/sda3 /mnt/var/cache
  mount -o noatime,compress=lzo,space_cache,subvol=@home /dev/sda3 /mnt/home
  mount -o noatime,compress=lzo,space_cache,subvol=@snapshots /dev/sda3 /mnt/.snapshots
  mount /dev/sda1 /mnt/boot/efi
}

if [[ "$install_all" == "clean_drive" ]]; then
  _install_all
else
  echo 'Форматирование дисков'
  ### Форматировать BOOT ? Да/Нет
  if read -re -p "Форматировать boot? [y/N]: " ans && [[ $ans == 'y' || $ans == 'Y' ]]; then
    mkfs.fat -F32 $boot
  else
    echo
  fi
  mkswap -L swap $swap
  swapon $swap
  mkfs.btrfs -f -L arch $root
  mount $root /mnt
  #####создадим подтома под root и домашний каталог пользователя и для снапшотов:
  btrfs subvolume create /mnt/arch_root
  btrfs subvolume create /mnt/arch_home
  btrfs subvolume create /mnt/arch_snapshots
  btrfs subvolume create /mnt/arch_cache
  umount /mnt
  mount -o noatime,compress=lzo,space_cache,subvol=arch_root $root /mnt
  mkdir -p /mnt/{home,boot,boot/efi,var,var/cache,.snapshots}
  mount -o noatime,compress=lzo,space_cache,subvol=arch_cache $root /mnt/var/cache
  mount -o noatime,compress=lzo,space_cache,subvol=arch_home $root /mnt/home
  mount -o noatime,compress=lzo,space_cache,subvol=arch_snapshots $root /mnt/.snapshots
  mount $boot /mnt/boot/efi
fi

echo 'Сортировка зеркал для загрузки.'
reflector -a 12 -l 15 -p https,http --sort rate --save /etc/pacman.d/mirrorlist --verbose
pacman -Syy

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl os-prober grub-btrfs

echo 'fstab'
genfstab -pU /mnt >> /mnt/etc/fstab

###arch-chroot /mnt sh -c "$(curl -fsSL git.io/archuefi2.sh)"
arch-chroot /mnt sh -c "$(curl -L https://raw.githubusercontent.com/alexdrozd64/archbtrfs/main/archuefi2.sh)"
