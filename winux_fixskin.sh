#!/bin/bash

PREFIX="$HOME/.wine32"
BACKUP_DIR="$HOME/wine-prefix-backup"

pause() {
    echo
    read -rp "Nhan Enter de tiep tuc..."
}

header() {
    clear
    echo "=============================================="
    echo "        WINE AUTO REPAIR PRO"
    echo "        Ubuntu / Winux 11"
    echo "=============================================="
    echo "Prefix hien tai: $PREFIX"
    echo "=============================================="
}

set_prefix_env() {
    export WINEPREFIX="$PREFIX"
}

install_base() {
    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings

    if [ ! -f /etc/apt/keyrings/winehq-archive.key ]; then
        sudo wget -O /etc/apt/keyrings/winehq-archive.key \
        https://dl.winehq.org/wine-builds/winehq.key
    fi

    if [ ! -f /etc/apt/sources.list.d/winehq.sources ]; then
        sudo wget -NP /etc/apt/sources.list.d/ \
        https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
    fi

    sudo apt update
    sudo apt install -y \
        winehq-stable \
        winetricks \
        cabextract \
        p7zip-full \
        unzip \
        wget \
        curl \
        zenity \
        file
}

create_prefix_32() {
    PREFIX="$HOME/.wine32"
    export WINEARCH=win32
    export WINEPREFIX="$PREFIX"
    wineboot -u
}

create_prefix_64() {
    PREFIX="$HOME/.wine64"
    unset WINEARCH
    export WINEPREFIX="$PREFIX"
    wineboot -u
}

install_fonts() {
    set_prefix_env
    winetricks -q corefonts tahoma liberation cjkfonts
}

install_vcrun() {
    set_prefix_env
    winetricks -q \
        vcrun6 \
        vcrun2005 \
        vcrun2008 \
        vcrun2010 \
        vcrun2012 \
        vcrun2013 \
        vcrun2015 \
        vcrun2017 \
        vcrun2019 \
        vcrun2022
}

install_dotnet() {
    set_prefix_env
    winetricks -q dotnet35 dotnet40 dotnet48
}

install_directx() {
    set_prefix_env
    winetricks -q \
        directx9 \
        d3dx9 \
        d3dcompiler_43 \
        d3dcompiler_47 \
        xact \
        xinput
}

install_dxvk() {
    set_prefix_env
    winetricks -q dxvk
}

install_common_dll() {
    set_prefix_env
    winetricks -q \
        gdiplus \
        msxml3 \
        msxml4 \
        msxml6 \
        riched20 \
        riched30 \
        riched32 \
        comctl32 \
        mfc42 \
        vb6run \
        vbrun6 \
        quartz \
        devenum \
        wmp9
}

fix_innosetup() {
    set_prefix_env
    echo "Dang fix Inno Setup..."
    install_fonts
    winetricks -q gdiplus riched20 riched30 msxml3 msxml6 comctl32 mfc42 win7
    clear_temp
    wineboot -u
}

fix_isskin() {
    set_prefix_env
    echo "Dang fix loi isskin.dll..."
    winetricks -q \
        corefonts \
        tahoma \
        gdiplus \
        riched20 \
        riched30 \
        vcrun6 \
        vcrun2008 \
        vcrun2010 \
        vcrun2013 \
        vcrun2015 \
        mfc42 \
        comctl32 \
        win7

    clear_temp
    wineboot -u
}

fix_nsis() {
    set_prefix_env
    echo "Dang fix NSIS..."
    install_fonts
    winetricks -q vcrun2008 vcrun2010 gdiplus win7
    clear_temp
}

fix_installshield() {
    set_prefix_env
    echo "Dang fix InstallShield..."
    winetricks -q \
        corefonts \
        tahoma \
        vcrun2005 \
        vcrun2008 \
        vcrun2010 \
        mfc42 \
        msxml3 \
        msxml6 \
        gdiplus \
        win7
    clear_temp
}

fix_msi() {
    set_prefix_env
    echo "Dang fix MSI Installer..."
    winetricks -q msxml3 msxml6 vcrun2008 vcrun2010 gdiplus win7
    wine msiexec /regserver
}

fix_runtime_all() {
    set_prefix_env
    install_fonts
    install_vcrun
    install_directx
    install_common_dll
}

install_all() {
    install_base
    create_prefix_32
    install_fonts
    install_vcrun
    install_dotnet
    install_directx
    install_dxvk
    install_common_dll
    fix_innosetup
    fix_isskin
}

clear_temp() {
    set_prefix_env
    echo "Dang xoa TEMP..."
    rm -rf "$PREFIX/drive_c/users/$USER/AppData/Local/Temp/"*
    rm -rf "$PREFIX/drive_c/windows/temp/"*
}

winecfg_open() {
    set_prefix_env
    winecfg
}

regedit_open() {
    set_prefix_env
    wine regedit
}

taskmgr_open() {
    set_prefix_env
    wine taskmgr
}

explorer_open() {
    set_prefix_env
    wine explorer
}

uninstaller_open() {
    set_prefix_env
    wine uninstaller
}

winetricks_gui() {
    set_prefix_env
    winetricks
}

run_exe() {
    set_prefix_env
    read -rp "Nhap duong dan file EXE: " exe
    wine "$exe"
}

run_exe_silent() {
    set_prefix_env
    read -rp "Nhap duong dan file EXE: " exe
    wine "$exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
}

run_msi() {
    set_prefix_env
    read -rp "Nhap duong dan file MSI: " msi
    wine msiexec /i "$msi"
}

backup_prefix() {
    mkdir -p "$BACKUP_DIR"
    name="wineprefix-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$BACKUP_DIR/$name" -C "$HOME" "$(basename "$PREFIX")"
    echo "Da backup: $BACKUP_DIR/$name"
}

restore_prefix() {
    mkdir -p "$BACKUP_DIR"
    echo "Danh sach backup:"
    ls -lh "$BACKUP_DIR"
    echo
    read -rp "Nhap ten file backup: " file
    if [ -f "$BACKUP_DIR/$file" ]; then
        rm -rf "$PREFIX"
        tar -xzf "$BACKUP_DIR/$file" -C "$HOME"
        echo "Da restore."
    else
        echo "Khong tim thay file."
    fi
}

delete_prefix() {
    read -rp "Ban chac chan muon xoa $PREFIX ? (y/N): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        rm -rf "$PREFIX"
        echo "Da xoa $PREFIX"
    fi
}

wine_info() {
    set_prefix_env
    echo "Wine:"
    wine --version
    echo
    echo "Winetricks:"
    winetricks --version
    echo
    echo "Prefix:"
    echo "$PREFIX"
    echo
    echo "Kien truc:"
    if [ -f "$PREFIX/system.reg" ]; then
        grep -i "#arch" "$PREFIX/system.reg" | head
    fi
}

change_prefix() {
    header
    echo "1) Dung prefix 32-bit: ~/.wine32"
    echo "2) Dung prefix 64-bit: ~/.wine64"
    echo "3) Nhap prefix tuy chon"
    echo
    read -rp "Chon: " c

    case "$c" in
        1) PREFIX="$HOME/.wine32" ;;
        2) PREFIX="$HOME/.wine64" ;;
        3)
            read -rp "Nhap duong dan prefix: " p
            PREFIX="$p"
            ;;
    esac
}

set_windows_xp() {
    set_prefix_env
    winetricks -q winxp
}

set_windows_7() {
    set_prefix_env
    winetricks -q win7
}

set_windows_10() {
    set_prefix_env
    winetricks -q win10
}

while true; do
    header
    echo "========== CAI DAT =========="
    echo "1) Cai Wine Stable + Winetricks"
    echo "2) Tao Prefix 32-bit"
    echo "3) Tao Prefix 64-bit"
    echo "4) Doi Prefix"
    echo
    echo "========== THU VIEN =========="
    echo "5) Cai Fonts"
    echo "6) Cai Visual C++ Runtime"
    echo "7) Cai .NET Framework"
    echo "8) Cai DirectX"
    echo "9) Cai DXVK"
    echo "10) Cai DLL bo sung"
    echo "11) Cai tat ca Runtime"
    echo "12) Cai DAT TAT CA"
    echo
    echo "========== FIX LOI =========="
    echo "13) Fix Inno Setup"
    echo "14) Fix isskin.dll"
    echo "15) Fix NSIS"
    echo "16) Fix InstallShield"
    echo "17) Fix MSI Installer"
    echo "18) Xoa Temp"
    echo
    echo "========== WINDOWS VERSION =========="
    echo "19) Set Windows XP"
    echo "20) Set Windows 7"
    echo "21) Set Windows 10"
    echo
    echo "========== TOOLS =========="
    echo "22) WineCFG"
    echo "23) Regedit"
    echo "24) Task Manager"
    echo "25) Explorer"
    echo "26) Uninstaller"
    echo "27) Winetricks GUI"
    echo
    echo "========== CHAY FILE =========="
    echo "28) Chay EXE"
    echo "29) Chay EXE Silent"
    echo "30) Chay MSI"
    echo
    echo "========== BACKUP =========="
    echo "31) Backup Prefix"
    echo "32) Restore Prefix"
    echo "33) Xoa Prefix"
    echo "34) Thong tin Wine"
    echo
    echo "0) Thoat"
    echo
    read -rp "Chon so: " ch

    case "$ch" in
        1) header; install_base; pause ;;
        2) header; create_prefix_32; pause ;;
        3) header; create_prefix_64; pause ;;
        4) change_prefix; pause ;;
        5) header; install_fonts; pause ;;
        6) header; install_vcrun; pause ;;
        7) header; install_dotnet; pause ;;
        8) header; install_directx; pause ;;
        9) header; install_dxvk; pause ;;
        10) header; install_common_dll; pause ;;
        11) header; fix_runtime_all; pause ;;
        12) header; install_all; pause ;;
        13) header; fix_innosetup; pause ;;
        14) header; fix_isskin; pause ;;
        15) header; fix_nsis; pause ;;
        16) header; fix_installshield; pause ;;
        17) header; fix_msi; pause ;;
        18) header; clear_temp; pause ;;
        19) header; set_windows_xp; pause ;;
        20) header; set_windows_7; pause ;;
        21) header; set_windows_10; pause ;;
        22) winecfg_open ;;
        23) regedit_open ;;
        24) taskmgr_open ;;
        25) explorer_open ;;
        26) uninstaller_open ;;
        27) winetricks_gui ;;
        28) run_exe; pause ;;
        29) run_exe_silent; pause ;;
        30) run_msi; pause ;;
        31) header; backup_prefix; pause ;;
        32) header; restore_prefix; pause ;;
        33) header; delete_prefix; pause ;;
        34) header; wine_info; pause ;;
        0) exit 0 ;;
        *) echo "Sai lua chon."; pause ;;
    esac
done
