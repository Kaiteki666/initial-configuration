#!/bin/bash

# 1. Виконуємо встановлення Node-RED
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi  --restart --no-init

# 2. Запускаємо Node-RED, щоб створився файл settings.js
echo "Запускаємо Node-RED для ініціалізації файлів..."
node-red-start &
sleep 10  # Зачекаємо кілька секунд, щоб Node-RED запустився і створив налаштування
node-red-stop

# 3. Генеруємо парольний хеш
PASSWORD="23142314qW"
HASHED_PASSWORD=$(echo "$PASSWORD" | node-red admin hash-pw)

# 4. Оновлюємо файл settings.js
SETTINGS_FILE="$HOME/.node-red/settings.js"

# Перевіряємо, чи існує файл
if [ -f "$SETTINGS_FILE" ]; then
    # Використовуємо sed для розкоментування та заміни потрібних рядків
    sed -i '/\/\/adminAuth: {/{N;N;N;N;s/\/\/adminAuth: {/adminAuth: {/;s/\/\/ *type: "credentials",/    type: "credentials",/;s/\/\/ *users: \[{/    users: \[{/}' "$SETTINGS_FILE"

    sed -i '/username: "admin",/{s/\/\/ *username: "admin",/        username: "kaiteki",/;N;s/\/\/ *password: "PASSWORD"/        password: "'"$HASHED_PASSWORD"'"/;N;s/\/\/ *permissions: "\*"/        permissions: "\*"/}' "$SETTINGS_FILE"

    echo "Файл settings.js успішно оновлений."
else
    echo "Файл settings.js не знайдено!"
fi

echo "Node-RED встановлено та налаштовано з користувачем kaiteki і паролем $PASSWORD."
