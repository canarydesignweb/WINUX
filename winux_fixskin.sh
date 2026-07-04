
#!/bin/bash

PREFIX="$HOME/.wine32"

clear

echo "========================================"
echo "   Inno Setup Wine Fix Tool v1.0"
echo "========================================"

if ! command -v winetricks >/dev/null 2>&1; then
    echo "Winetricks chua duoc cai."
    echo
    echo "Chay:"
    echo "sudo apt install winetricks"
    exit 1
fi

if [ ! -d "$PREFIX" ]; then
    echo "Khong tim thay Wine Prefix."
    echo

    read -p "Tao Prefix 32-bit? (Y/n): " a

    if [[ ! "$a" =~ ^[Nn]$ ]]; then
        export WINEARCH=win32
        export WINEPREFIX="$PREFIX"
        wineboot -u
    else
        exit
    fi
fi

export WINEPREFIX="$PREFIX"

echo
echo "Dang cai Fonts..."
winetricks -q corefonts tahoma

echo
echo "Dang cai VC Runtime..."
winetricks -q \
vcrun6 \
vcrun2005 \
vcrun2008 \
vcrun2010 \
vcrun2013 \
vcrun2015 \
vcrun2019

echo
echo "Dang cai GDI..."
winetricks -q \
gdiplus \
riched20 \
riched30 \
riched32

echo
echo "Dang cai XML..."
winetricks -q \
msxml3 \
msxml6

echo
echo "Dang cai Common Control..."
winetricks -q \
comctl32 \
mfc42

echo
echo "Dang cai DirectX..."
winetricks -q \
directx9 \
d3dx9

echo
echo "Dat Windows Version = Windows 7"
winetricks -q win7

echo
echo "Xoa TEMP..."
rm -rf "$PREFIX/drive_c/users/$USER/AppData/Local/Temp/"*

echo
echo "Dang rebuild Prefix..."
wineboot -u

sleep 3

echo
echo "========================================"
echo "Fix hoan tat."
echo "========================================"
echo
echo "Hay chay lai:"
echo
echo "WINEPREFIX=$PREFIX wine setup.exe"
echo
