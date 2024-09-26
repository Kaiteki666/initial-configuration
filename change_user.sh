#!/bin/bash

# Ім'я користувача orangepi, для якого буде змінено ім'я та пароль
USER_ORANGEPI="orangepi"

# Перевірка наявності двох аргументів (нове ім'я користувача та пароль)
if [ "$#" -ne 2 ]; then
    echo "Використання: $0 <нове ім'я користувача> <пароль>"
    exit 1
fi

# Отримання аргументів
NEW_USERNAME=$1
PASSWORD=$2

# Зміна пароля для існуючого користувача orangepi
if id "$USER_ORANGEPI" &>/dev/null; then
    echo "$USER_ORANGEPI:$PASSWORD" | sudo chpasswd
    echo "Пароль для користувача $USER_ORANGEPI був змінений на $PASSWORD."
else
    echo "Користувач $USER_ORANGEPI не знайдений."
fi

# Зміна імені користувача orangepi на нове ім'я
if id "$USER_ORANGEPI" &>/dev/null; then
    sudo usermod -l "$NEW_USERNAME" "$USER_ORANGEPI"
    # Зміна домашнього каталогу, якщо це потрібно
    sudo usermod -d "/home/$NEW_USERNAME" -m "$NEW_USERNAME"
    echo "Ім'я користувача $USER_ORANGEPI було змінено на $NEW_USERNAME."
else
    echo "Користувач $USER_ORANGEPI не знайдений."
fi
