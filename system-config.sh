#!/bin/bash

# Перевірка наявності всіх аргументів
if [ $# -ne 5 ]; then
  echo "Usage: $0 <login> <change_password> <cloudflare_token> <nodered_username> <nodered_password>"
  exit 1
fi

# Зчитування аргументів
LOGIN=$1
CHANGE_PASSWORD=$2
CLOUDFLARE_TOKEN=$3
NODERED_USERNAME=$4
NODERED_PASSWORD=$5

# Оновлення пакетів
echo "Updating packages..."
sudo apt update
sudo apt upgrade -y

# Налаштування watchdog таймера
echo "Configuring watchdog timer..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/refs/heads/main/configurate-watchdog.sh | sudo bash -s

# Встановлення cloudflared
echo "Installing cloudflared..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/main/install-cloudflared.sh | bash -s -- "$CLOUDFLARE_TOKEN"

# Встановлення Node-RED
echo "Installing Node-RED..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/refs/heads/main/install-node-red.sh | sudo bash -s -- "$NODERED_USERNAME" "$NODERED_PASSWORD"

# Зміна користувача
echo "Changing user..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/refs/heads/main/change_user.sh | sudo bash -s -- "$LOGIN" "$CHANGE_PASSWORD"

# Перезавантаження системи
echo "The system will reboot in 20 seconds..."
sleep 20
sudo reboot

