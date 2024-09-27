#!/bin/bash

# Script Name: Linux Setup Automation
# Description: This script updates packages, configures the watchdog timer,
#              changes the user, installs cloudflared, and installs Node-RED.

# Display script name and description
echo -e "\033[34m[INFO]\033[0m Running \033[36mLinux Setup Automation Script\033[0m"

# Check for the correct number of arguments
if [ $# -ne 5 ]; then
  echo -e "\033[31m[ERROR]\033[0m Usage: $0 <login> <change_password> <cloudflare_token> <nodered_username> <nodered_password>"
  exit 1
fi

# Read arguments
LOGIN=$1
CHANGE_PASSWORD=$2
CLOUDFLARE_TOKEN=$3
NODERED_USERNAME=$4
NODERED_PASSWORD=$5

# Update packages
echo -e "\033[34m[INFO]\033[0m Updating packages..."
sudo apt update
sudo apt upgrade -y

# Configure watchdog timer
echo -e "\033[34m[INFO]\033[0m Configuring watchdog timer..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/refs/heads/main/configurate-watchdog.sh | sudo bash -s

# Install cloudflared
echo -e "\033[34m[INFO]\033[0m Installing cloudflared..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/main/install-cloudflared.sh | bash -s -- "$CLOUDFLARE_TOKEN"

# Install Node-RED
echo -e "\033[34m[INFO]\033[0m Installing Node-RED..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/refs/heads/main/install-node-red.sh | sudo bash -s -- "$NODERED_USERNAME" "$NODERED_PASSWORD"

# Change user
echo -e "\033[34m[INFO]\033[0m Changing user..."
curl -sL https://raw.githubusercontent.com/Kaiteki666/initial-configuration/refs/heads/main/change_user.sh | sudo bash -s -- "$LOGIN" "$CHANGE_PASSWORD"

# Reboot the system
echo -e "\033[34m[INFO]\033[0m The system will reboot in 20 seconds..."
sleep 20
sudo reboot
