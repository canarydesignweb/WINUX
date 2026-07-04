#!/bin/bash

while true; do
clear
echo "=============================="
echo "   WINUX CLEAN MENU"
echo "=============================="
echo "1) Tat thong bao Activate Winux"
echo "2) Xoa shortcut Buy Pro tren Desktop"
echo "3) Kiem tra file slui"
echo "4) Khoi phuc slui"
echo "5) Tim file lien quan Winux/PowerTools"
echo "6) Thoat"
echo "=============================="
read -p "Chon so: " choice

case $choice in
  1)
    echo "Dang tat thong bao Activate Winux..."
    if [ -f /usr/bin/slui ]; then
      sudo chmod -x /usr/bin/slui
      echo "Da tat /usr/bin/slui"
    else
      echo "Khong tim thay /usr/bin/slui"
    fi
    read -p "Nhan Enter de tiep tuc..."
    ;;

  2)
    echo "Dang xoa shortcut Buy Pro..."
    rm -f ~/Desktop/buy-pro.desktop
    rm -f ~/Desktop/*buy-pro*.desktop
    echo "Da xoa shortcut neu co."
    read -p "Nhan Enter de tiep tuc..."
    ;;

  3)
    echo "Thong tin /usr/bin/slui:"
    which slui
    ls -l /usr/bin/slui 2>/dev/null
    file /usr/bin/slui 2>/dev/null
    read -p "Nhan Enter de tiep tuc..."
    ;;

  4)
    echo "Dang khoi phuc quyen chay slui..."
    if [ -f /usr/bin/slui ]; then
      sudo chmod +x /usr/bin/slui
      echo "Da khoi phuc /usr/bin/slui"
    else
      echo "Khong tim thay /usr/bin/slui"
    fi
    read -p "Nhan Enter de tiep tuc..."
    ;;

  5)
    echo "Dang tim file lien quan..."
    find /opt /usr ~/.config ~/Desktop -iname "*winux*" -o -iname "*powertools*" -o -iname "*buy-pro*" -o -iname "*slui*" 2>/dev/null
    read -p "Nhan Enter de tiep tuc..."
    ;;

  6)
    echo "Thoat."
    exit 0
    ;;

  *)
    echo "Lua chon khong hop le."
    read -p "Nhan Enter de tiep tuc..."
    ;;
esac
done
