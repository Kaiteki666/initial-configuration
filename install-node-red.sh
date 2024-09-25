#!/bin/bash

# 1. Запускаємо скрипт для встановлення Node-RED та Node.js
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi --restart --no-init

# 2. Генеруємо хеш пароля
PASSWORD="23142314qW"
HASHED_PASSWORD=$(node-red admin hash-pw <<EOF
$PASSWORD
EOF
)

# 3. Перевіряємо чи згенеровано хеш
if [ -z "$HASHED_PASSWORD" ]; then
  echo "Хеш пароля не згенеровано!"
  exit 1
fi

# 4. Відкриваємо settings.js та вносимо зміни
SETTINGS_FILE="$HOME/.node-red/settings.js"
SEARCH_TEXT="/** To password protect the Node-RED editor and admin API, the following"
NEW_CONFIG="adminAuth: {
        \"type\": \"credentials\",
        \"users\": [
            {
                \"username\": \"kaiteki\",
                \"password\": \"$HASHED_PASSWORD\",
                \"permissions\": \"*\"
            }
        ]
},"

# Використовуємо sed для пошуку та додавання конфігурації
if grep -q "$SEARCH_TEXT" "$SETTINGS_FILE"; then
  # Вставляємо нову конфігурацію після коментаря
  sed -i "/$SEARCH_TEXT/a $NEW_CONFIG" "$SETTINGS_FILE"
  echo "Файл settings.js оновлено!"
else
  echo "Не знайдено потрібного коментаря у файлі settings.js!"
fi
