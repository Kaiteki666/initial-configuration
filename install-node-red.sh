#!/bin/bash

# Перевіряємо, чи передано пароль
if [ -z "$1" ]; then
    echo "Будь ласка, передайте пароль як аргумент."
    exit 1
fi

# Зберігаємо пароль в змінній
PASSWORD="$1"

# 1. Виконуємо встановлення Node-RED
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi  --restart --no-init

# 2. Запускаємо Node-RED, щоб створився файл settings.js
echo "Запускаємо Node-RED для ініціалізації файлів..."
node-red-start &
sleep 15  # Чекаємо, щоб Node-RED створив налаштування
node-red-stop

# 3. Генеруємо парольний хеш і видаляємо "Password:" з хешу
HASHED_PASSWORD=$(echo "$PASSWORD" | node-red admin hash-pw | grep -o '\$.*')

# 4. Оновлюємо файл settings.js
SETTINGS_FILE="$HOME/.node-red/settings.js"
echo "Перевіряємо файл налаштувань за шляхом: $SETTINGS_FILE"

if [ -f "$SETTINGS_FILE" ]; then
    echo "Файл settings.js знайдено. Розпочинаємо заміну закоментованого блоку..."

    # Заміна закоментованого блоку на повністю розкоментований і видалення зайвої закоментованої дужки
    sed -i '/\/\/adminAuth: {/,+7c\    adminAuth: {\n        type: "credentials",\n        users: [{\n            username: "kaiteki",\n            password: "'"$HASHED_PASSWORD"'",\n            permissions: "*"\n        }]\n    },' "$SETTINGS_FILE"

    echo "Файл settings.js успішно оновлений."
else
    echo "Помилка: файл settings.js не знайдено!"
fi

echo "Node-RED встановлено та налаштовано з користувачем kaiteki і паролем."
