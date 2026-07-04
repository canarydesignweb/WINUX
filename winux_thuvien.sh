#!/bin/bash

set -e

clear

echo "======================================"
echo " Wine Auto Installer"
echo " Ubuntu 24.04 / Winux"
echo "======================================"

sleep 2

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
wine-stable \
wine-stable-i386 \
wine32 \
wine64 \
winetricks \
cabextract \
p7zip-full \
unzip \
wget \
curl

echo
echo "Creating 32-bit Wine Prefix..."
echo

export WINEARCH=win32
export WINEPREFIX=$HOME/.wine32

wineboot -u

sleep 3

echo
echo "Installing Core Fonts..."
winetricks -q corefonts

echo
echo "Installing VC Runtime..."
winetricks -q vcrun2005
winetricks -q vcrun2008
winetricks -q vcrun2010
winetricks -q vcrun2012
winetricks -q vcrun2013
winetricks -q vcrun2015

echo
echo "Installing .NET..."
winetricks -q dotnet35
winetricks -q dotnet40
winetricks -q dotnet48

echo
echo "Installing DirectX..."
winetricks -q directx9

echo
echo "Installing DXVK..."
winetricks -q dxvk

echo
echo "Installing GDI+..."
winetricks -q gdiplus

echo
echo "Installing MSXML..."
winetricks -q msxml3
winetricks -q msxml6

echo
echo "Installing Common DLL..."
winetricks -q riched20
winetricks -q riched30
winetricks -q riched32

echo
echo "Installing IE8..."
winetricks -q ie8

echo
echo "Configuring Windows 10..."
winetricks -q win10

echo
echo "Done."

echo
echo "Wine Prefix:"
echo "$HOME/.wine32"

echo
echo "Run application with:"
echo

echo 'WINEPREFIX=$HOME/.wine32 wine setup.exe'

echo
echo "===================================="
echo " Installation Complete"
echo "===================================="
