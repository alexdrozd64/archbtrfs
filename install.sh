#!/usr/bin/bash

repo_path="https://raw.githubusercontent.com/alexdrozd64/script_instal_archlinux/main"
install_sh="archuefi1.sh"

loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true

function _BOOT {
  echo
  read -p "Укажите BOOT раздел: " boot
  echo
  echo "BOOT раздел будет: " $boot
  echo "Возврат в основное меню $REPLY"
}

function _SWAP {
  echo
  read -p "Укажите SWAP раздел: " swap
  echo
  echo "SWAP раздел будет: " $swap
  echo "Возврат в основное меню $REPLY"
}

function _ROOT {
  echo
  read -p "Укажите ROOT раздел: " root
  echo
  echo "ROOT раздел будет: " $root
  echo "Возврат в основное меню $REPLY"
}

function _ROOT_BOOT_SWAP {
  echo "Укажите расположение разделов ROOT, BOOT и SWAP"
  echo
  PS3='
Дополнительное меню, Выберите действие: '
  options=(
    "Выбрать Boot"
    "Выбрать Swap"
    "Выбрать Root"
    "Проверить выбранные разделы"
    "Установить на выбранные разделы"
    "Выход в основное меню"
  )
  select opt in "${options[@]}"
  do
  case $opt in
    "Выбрать Boot")
      clear
      echo -e "Ниже показаны все разделы вашего диска, \nвыберите какой раздел хотите использовать для BOOT раздела? \nУкажите полный путь, например /dev/sda1"
      echo
      lsblk -p
      echo
      _BOOT
      _ROOT_BOOT_SWAP
      ;;
    "Выбрать Swap")
      clear
      echo -e "Ниже показаны все разделы вашего диска, \nвыберите какой раздел хотите использовать для SWAP раздела? \nУкажите полный путь, например /dev/sda1"
      echo
      lsblk -p
      echo
      _SWAP
      _ROOT_BOOT_SWAP
      ;;
    "Выбрать Root")
      clear
      echo -e "Ниже показаны все разделы вашего диска, \nвыберите какой раздел хотите использовать для ROOT раздела? \nУкажите полный путь, например /dev/sda1"
      echo
      lsblk -p
      echo
      _ROOT
      _ROOT_BOOT_SWAP
      ;;
    "Проверить выбранные разделы")
      clear
      echo -e "boot: $boot | swap: $swap | root: $root"
      echo
      _ROOT_BOOT_SWAP
      ;;
    "Установить на выбранные разделы")
      sh -c "$(curl -LO $repo_path/$install_sh $boot $swap $root)"
      exit
      ;;
    "Выход в основное меню")
      _MENU
      ;;
    *) echo "invalid option $REPLY";;
  esac
done
}

function _MENU {
  # clear
  echo -e "Добро пожаловать"
  echo
  PS3='
Основное меню, Выберите действие: '
  options=(
    "Назначить root пароль"
    "Включить sshd"
    "Установить на ПУСТОЙ диск"
    "Установить рядом с существующей системой"
    "Quit"
  )
  select opt in "${options[@]}"
  do
    case $opt in
      "Назначить root пароль")
        clear
        passwd
        echo
        echo "Возврат в меню $REPLY"
        echo
        _MENU
        ;;
      "Включить sshd")
        clear
        systemctl list-unit-files | grep sddm >/dev/null && systemctl start sshd || echo "no openssh pkg"
        echo
        echo "Возврат в меню $REPLY"
        echo
        _MENU
        ;;
      "Установить на ПУСТОЙ диск")
        sh -c "$(curl -LO $repo_path/$install_sh clean_drive)"
        break
        ;;
      "Установить рядом с существующей системой")
        _ROOT_BOOT_SWAP
        break
        ;;
      "Quit")
        exit
        ;;
      *) echo "invalid option $REPLY";;
    esac
  done
}

_MENU
