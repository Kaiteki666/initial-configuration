#!/bin/bash

# Ім'я користувача orangepi, для якого буде змінено пароль
USER_ORANGEPI="orangepi"

# Перевірка наявності двох аргументів (ім'я нового користувача та пароль)
if [ "$#" -ne 2 ]; then
    echo "Використання: $0 <ім'я нового користувача> <пароль>"
    exit 1
fi

# Отримання аргументів
NEW_USER=$1
PASSWORD=$2

# Зміна пароля для існуючого користувача orangepi
if id "$USER_ORANGEPI" &>/dev/null; then
    echo "$USER_ORANGEPI:$PASSWORD" | sudo chpasswd
    echo "Пароль для користувача $USER_ORANGEPI був змінений на $PASSWORD."
else
    echo "Користувач $USER_ORANGEPI не знайдений."
fi

# Створення нового користувача
if id "$NEW_USER" &>/dev/null; then
    echo "Користувач $NEW_USER вже існує."
else
    sudo useradd -m -p "$(openssl passwd -1 $PASSWORD)" "$NEW_USER"
    echo "Користувача $NEW_USER було створено з паролем $PASSWORD."
fi
