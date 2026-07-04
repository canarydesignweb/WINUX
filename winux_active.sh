#!/bin/bash

BACKUP_DIR="$HOME/winux-clean-backup"
DATE_NOW="$(date +%Y%m%d-%H%M%S)"

pause() {
    echo
    read -rp "Nhan Enter de tiep tuc..."
}

header() {
    clear
    echo "=========================================="
    echo "        WINUX CLEAN FULL MENU"
    echo "=========================================="
}

make_backup_dir() {
    mkdir -p "$BACKUP_DIR"
}

refresh_kde_menu() {
    echo "[*] Dang lam moi menu KDE..."
    if command -v kbuildsycoca6 >/dev/null 2>&1; then
        kbuildsycoca6
    elif command -v kbuildsycoca5 >/dev/null 2>&1; then
        kbuildsycoca5
    else
        echo "Khong tim thay kbuildsycoca5/6. Hay dang xuat/dang nhap lai."
    fi
}

show_system_info() {
    header
    echo "===== /etc/os-release ====="
    cat /etc/os-release 2>/dev/null
    echo
    echo "===== Desktop ====="
    echo "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP"
    echo "DESKTOP_SESSION=$DESKTOP_SESSION"
    pause
}

check_slui() {
    header
    echo "===== Kiem tra slui ====="
    echo
    echo "which slui:"
    which slui 2>/dev/null || echo "Khong tim thay trong PATH"
    echo
    echo "ls -l /usr/bin/slui:"
    ls -l /usr/bin/slui 2>/dev/null || echo "Khong co /usr/bin/slui"
    echo
    echo "file /usr/bin/slui:"
    file /usr/bin/slui 2>/dev/null || true
    pause
}

disable_slui() {
    header
    echo "===== Vo hieu hoa /usr/bin/slui ====="
    if [ -f /usr/bin/slui ]; then
        make_backup_dir
        cp -n /usr/bin/slui "$BACKUP_DIR/slui.backup" 2>/dev/null
        sudo chmod -x /usr/bin/slui
        echo "Da vo hieu hoa:"
        ls -l /usr/bin/slui
    else
        echo "Khong tim thay /usr/bin/slui"
    fi
    pause
}

restore_slui() {
    header
    echo "===== Khoi phuc /usr/bin/slui ====="
    if [ -f /usr/bin/slui ]; then
        sudo chmod +x /usr/bin/slui
        echo "Da khoi phuc quyen chay:"
        ls -l /usr/bin/slui
    elif [ -f "$BACKUP_DIR/slui.backup" ]; then
        sudo cp "$BACKUP_DIR/slui.backup" /usr/bin/slui
        sudo chmod +x /usr/bin/slui
        echo "Da khoi phuc tu backup."
        ls -l /usr/bin/slui
    else
        echo "Khong co /usr/bin/slui va khong co backup."
    fi
    pause
}

find_activate_launchers() {
    header
    echo "===== Tim launcher Activate Winux / Buy Pro ====="
    echo
    echo "[*] Tim file ten buy-pro/slui/activate/winux..."
    find "$HOME/Desktop" \
         "$HOME/.local/share/applications" \
         /usr/share/applications \
         -type f \( \
            -iname "*buy-pro*.desktop" -o \
            -iname "*activate*.desktop" -o \
            -iname "*slui*.desktop" -o \
            -iname "*winux*.desktop" \
         \) 2>/dev/null
    echo
    echo "[*] Tim noi dung co Activate Winux / powertools..."
    grep -RIlE "Activate Winux|winux\.is/powertools|powertools|/usr/bin/slui|Exec=slui" \
        "$HOME/Desktop" \
        "$HOME/.local/share/applications" \
        /usr/share/applications 2>/dev/null
    pause
}

remove_buypro_launchers() {
    header
    echo "===== Xoa launcher Buy Pro / Activate Winux ====="
    make_backup_dir

    TARGETS=$(find "$HOME/Desktop" \
                   "$HOME/.local/share/applications" \
                   /usr/share/applications \
                   -type f \( \
                      -name "buy-pro.desktop" -o \
                      -iname "*buy-pro*.desktop" \
                   \) 2>/dev/null)

    CONTENT_TARGETS=$(grep -RIlE "Activate Winux|winux\.is/powertools" \
        "$HOME/Desktop" \
        "$HOME/.local/share/applications" \
        /usr/share/applications 2>/dev/null)

    ALL_TARGETS=$(printf "%s\n%s\n" "$TARGETS" "$CONTENT_TARGETS" | sort -u | sed '/^$/d')

    if [ -z "$ALL_TARGETS" ]; then
        echo "Khong tim thay launcher can xoa."
        pause
        return
    fi

    echo "Se xoa/backup cac file sau:"
    echo "$ALL_TARGETS"
    echo
    read -rp "Dong y xoa? (y/N): " ans

    if [[ "$ans" =~ ^[Yy]$ ]]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue

            backup_name="$BACKUP_DIR/$(echo "$f" | sed 's#/#_#g').$DATE_NOW.bak"

            if [ -w "$f" ]; then
                cp "$f" "$backup_name" 2>/dev/null
                rm -f "$f"
            else
                sudo cp "$f" "$backup_name" 2>/dev/null
                sudo rm -f "$f"
            fi

            echo "Da xoa: $f"
        done <<< "$ALL_TARGETS"

        refresh_kde_menu
        echo
        echo "Hoan tat. Neu menu van con, hay logout/login hoac reboot."
    else
        echo "Da huy."
    fi

    pause
}

hide_activate_launchers() {
    header
    echo "===== An launcher thay vi xoa ====="
    make_backup_dir

    FILES=$(grep -RIlE "Activate Winux|winux\.is/powertools" \
        "$HOME/Desktop" \
        "$HOME/.local/share/applications" \
        /usr/share/applications 2>/dev/null)

    if [ -z "$FILES" ]; then
        echo "Khong tim thay launcher de an."
        pause
        return
    fi

    echo "Se them Hidden=true vao:"
    echo "$FILES"
    echo
    read -rp "Dong y an? (y/N): " ans

    if [[ "$ans" =~ ^[Yy]$ ]]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            backup_name="$BACKUP_DIR/$(echo "$f" | sed 's#/#_#g').$DATE_NOW.bak"

            if [ -w "$f" ]; then
                cp "$f" "$backup_name" 2>/dev/null
                grep -q "^Hidden=true" "$f" || echo "Hidden=true" >> "$f"
            else
                sudo cp "$f" "$backup_name" 2>/dev/null
                sudo sh -c "grep -q '^Hidden=true' '$f' || echo 'Hidden=true' >> '$f'"
            fi

            echo "Da an: $f"
        done <<< "$FILES"

        refresh_kde_menu
    else
        echo "Da huy."
    fi

    pause
}

list_autostart() {
    header
    echo "===== User Autostart ====="
    ls -la "$HOME/.config/autostart" 2>/dev/null || echo "Khong co ~/.config/autostart"
    echo
    echo "===== System Autostart ====="
    ls -la /etc/xdg/autostart 2>/dev/null
    echo
    echo "===== Tim slui/winux/powertools trong autostart ====="
    grep -RInE "slui|winux|powertools|buy-pro|Activate Winux" \
        "$HOME/.config/autostart" /etc/xdg/autostart 2>/dev/null || echo "Khong thay."
    pause
}

find_winux_files() {
    header
    echo "===== Tim file lien quan Winux / PowerTools ====="
    find /opt /usr /usr/local "$HOME/.config" "$HOME/Desktop" \
        \( -iname "*winux*" -o \
           -iname "*powertools*" -o \
           -iname "*linuxfx*" -o \
           -iname "*buy-pro*" -o \
           -iname "*slui*" \) 2>/dev/null
    pause
}

list_winux_packages() {
    header
    echo "===== Package lien quan ====="
    dpkg -l | grep -Ei "winux|linuxfx|powertools|power-tools|power|slui" || echo "Khong thay package lien quan."
    pause
}

restore_deleted_launchers() {
    header
    echo "===== Backup trong $BACKUP_DIR ====="
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Chua co thu muc backup."
        pause
        return
    fi

    ls -lh "$BACKUP_DIR"
    echo
    echo "Muon khoi phuc file nao thi copy thu cong tu thu muc tren."
    echo "Vi du:"
    echo "sudo cp '$BACKUP_DIR/ten_file.bak' /usr/share/applications/buy-pro.desktop"
    pause
}

main_menu() {
    while true; do
        header
        echo "1) Thong tin he thong"
        echo "2) Kiem tra slui"
        echo "3) Vo hieu hoa slui"
        echo "4) Khoi phuc slui"
        echo "5) Tim launcher Activate Winux / Buy Pro"
        echo "6) Xoa launcher Activate Winux / Buy Pro"
        echo "7) An launcher Activate Winux / Buy Pro"
        echo "8) Liet ke Autostart"
        echo "9) Tim file Winux / PowerTools"
        echo "10) Liet ke package lien quan"
        echo "11) Refresh KDE menu"
        echo "12) Xem backup"
        echo "0) Thoat"
        echo
        read -rp "Chon so: " choice

        case "$choice" in
            1) show_system_info ;;
            2) check_slui ;;
            3) disable_slui ;;
            4) restore_slui ;;
            5) find_activate_launchers ;;
            6) remove_buypro_launchers ;;
            7) hide_activate_launchers ;;
            8) list_autostart ;;
            9) find_winux_files ;;
            10) list_winux_packages ;;
            11) header; refresh_kde_menu; pause ;;
            12) restore_deleted_launchers ;;
            0) exit 0 ;;
            *) echo "Lua chon sai."; pause ;;
        esac
    done
}

main_menu
