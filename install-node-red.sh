#!/bin/bash

# 1. Виконуємо встановлення Node-RED
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi  --restart --no-init

# 2. Генеруємо парольний хеш
PASSWORD="23142314qW"
HASHED_PASSWORD=$(echo "$PASSWORD" | node-red admin hash-pw)

# 3. Оновлюємо файл settings.js
SETTINGS_FILE="$HOME/.node-red/settings.js"

# Використовуємо sed для розкоментування та заміни потрібних рядків
sed -i '/\/\/adminAuth: {/{N;N;N;N;s/\/\/adminAuth: {/adminAuth: {/;s/\/\/ *type: "credentials",/    type: "credentials",/;s/\/\/ *users: \[{/    users: \[{/}' "$SETTINGS_FILE"

sed -i '/username: "admin",/{s/\/\/ *username: "admin",/        username: "kaiteki",/;N;s/\/\/ *password: "PASSWORD"/        password: "'"$HASHED_PASSWORD"'"/;N;s/\/\/ *permissions: "\*"/        permissions: "\*"/}' "$SETTINGS_FILE"

echo "Node-RED встановлено та налаштовано з користувачем kaiteki і паролем $PASSWORD."
