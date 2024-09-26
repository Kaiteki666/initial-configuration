#!/bin/bash

# 1. Виконуємо встановлення Node-RED
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi  --restart --no-init

# 2. Запускаємо Node-RED, щоб створився файл settings.js
echo "Запускаємо Node-RED для ініціалізації файлів..."
node-red-start &
sleep 15  # Зачекаємо, щоб Node-RED створив налаштування
node-red-stop

# 3. Генеруємо парольний хеш
PASSWORD="23142314qW"
HASHED_PASSWORD=$(echo "$PASSWORD" | node-red admin hash-pw)

# 4. Оновлюємо файл settings.js
SETTINGS_FILE="$HOME/.node-red/settings.js"
echo "Перевіряємо файл налаштувань за шляхом: $SETTINGS_FILE"

if [ -f "$SETTINGS_FILE" ]; then
    echo "Файл settings.js знайдено. Розпочинаємо редагування..."

    # 1. Розкоментовуємо рядок adminAuth
    sed -i 's/\/\/adminAuth: {/adminAuth: {/g' "$SETTINGS_FILE"

    # 2. Розкоментовуємо рядок з типом аутентифікації
    sed -i 's/\/\/ *type: "credentials",/    type: "credentials",/g' "$SETTINGS_FILE"

    # 3. Розкоментовуємо рядок з користувачами
    sed -i 's/\/\/ *users: \[{/    users: \[{/g' "$SETTINGS_FILE"

    # 4. Вставляємо ім'я користувача
    sed -i 's/\/\/ *username: "admin",/        username: "kaiteki",/g' "$SETTINGS_FILE"

    # 5. Розкоментовуємо і замінюємо парольний хеш
    sed -i 's/\/\/ *password: "PASSWORD"/        password: "'"$HASHED_PASSWORD"'"/g' "$SETTINGS_FILE"

    # 6. Розкоментовуємо права доступу
    sed -i 's/\/\/ *permissions: "\*"/        permissions: "\*"/g' "$SETTINGS_FILE"

    # 7. Розкоментовуємо закриття блоку
    sed -i 's/\/\/ *}]/    }]/g' "$SETTINGS_FILE"
    sed -i 's/\/\/ *},/    },/g' "$SETTINGS_FILE"

    echo "Файл settings.js успішно оновлений."
else
    echo "Помилка: файл settings.js не знайдено!"
fi

echo "Node-RED встановлено та налаштовано з користувачем kaiteki і паролем $PASSWORD."
