#!/bin/bash
# Bash Menu Script Example

loadkeys ru
setfont cyr-sun16


function _ALL {
  echo
  echo "Будет установлено на весь диск"
  echo
  curl -LO https://raw.githubusercontent.com/alexdrozd64/script_instal_archlinux/main/inastall_archlinuxuefi1.sh
  sh inastall_archlinuxuefi1.sh true
  
}

function _ROOT_BOOT_SWAP {
echo
echo "Укажите расположение разделов ROOT , BOOT и SWAP"
    echo
    PS3='Дополнительное меню : Please enter your choice: '
    options=("Выбрать Boot" "Выбрать Swap" "Выбрать Root" "Проверить выбранные разделы" "Установить на выбранные разделы" "Выход в основное меню")
    select opt in "${options[@]}"
    do
    case $opt in
        "Выбрать Root")
            _ROOT
            clear
            _ROOT_BOOT_SWAP
            ;;
        "Выбрать Swap")
            _SWAP
            clear
            _ROOT_BOOT_SWAP
            ;;
        "Выбрать Boot")
            _BOOT
            clear
            _ROOT_BOOT_SWAP
            ;;
        "Проверить выбранные разделы")
            echo “Свап - $swap Буут - $boot руут - $root”
            _ROOT_BOOT_SWAP
            exit
            ;;
         "Установить на выбранные разделы")
            sh inastall_archlinuxuefi1.sh $boot $swap $root
         ;;
         "Выход в основное меню")
           clear
           _MENU
         ;;
          *) echo "invalid option $REPLY";;
    esac
done
}
function _BOOT {
echo
echo "Ниже показаны все разделы вашего диска, выберите какой раздел хотите использовать для BOOT раздела?"
    echo
    lsblk
    echo
    read -p "Выберите раздел для BOOT - " boot
    echo
    echo "BOOT раздел будет - " $boot
    echo "Возврат в основное меню $REPLY"
}

function _ROOT {
echo
echo "Ниже показаны все разделы вашего диска, выберите какой раздел хотите использовать для ROOT раздела?"
    echo
    lsblk
    echo
    read -p "Выберите раздел для BOOT - " root
    echo
    echo "BOOT раздел будет - " $root
    echo "Возврат в основное меню $REPLY"
}

function _SWAP {
echo
echo "Ниже показаны все разделы вашего диска, выберите какой раздел хотите использовать для SWAP раздела?"
    echo
    lsblk
    echo
    read -p "Выберите раздел для SWAP - " swap
    echo
    echo "SWAP раздел будет - " $swap
    echo "Возврат в основное меню $REPLY"
}



function _MENU {
PS3='Основное меню : Please enter your choice: '
options=("Установить на ПУСТОЙ диск" "Установить рядом с существующей системой" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Установить на ПУСТОЙ диск")
            _ALL
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


#############  Основной код   ####################

_MENU
