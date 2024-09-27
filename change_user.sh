#!/bin/bash

# Username for orangepi, whose password will be changed
USER_ORANGEPI="orangepi"
USER_ROOT="root"

# Check if two arguments (new username and password) are provided
if [ "$#" -ne 2 ]; then
    echo -e "\e[31mUsage: $0 <new username> <password>\e[0m"
    exit 1
fi

# Get the arguments
NEW_USER=$1
PASSWORD=$2

# Change password for the existing user orangepi
if id "$USER_ORANGEPI" &>/dev/null; then
    echo "$USER_ORANGEPI:$PASSWORD" | sudo chpasswd
    echo -e "\e[32mPassword for user $USER_ORANGEPI has been changed to $PASSWORD.\e[0m"
else
    echo -e "\e[31mUser $USER_ORANGEPI not found.\e[0m"
fi

# Change password for the root user
if id "$USER_ROOT" &>/dev/null; then
    echo "$USER_ROOT:$PASSWORD" | sudo chpasswd
    echo -e "\e[32mPassword for user $USER_ROOT has been changed to $PASSWORD.\e[0m"
else
    echo -e "\e[31mUser $USER_ROOT not found.\e[0m"
fi

# Create a new user
if id "$NEW_USER" &>/dev/null; then
    echo -e "\e[33mUser $NEW_USER already exists.\e[0m"
else
    sudo useradd -m -p "$(openssl passwd -1 $PASSWORD)" "$NEW_USER"
    echo -e "\e[32mUser $NEW_USER has been created with password $PASSWORD.\e[0m"
fi

# Disable automatic login
sudo auto_login_cli.sh -d
echo -e "\e[34mAutomatic login has been disabled.\e[0m"
