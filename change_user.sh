#!/bin/bash

# Script Name: User Management Script
# Description: This script changes the password for the user 'orangepi', 
#              changes the root password, creates a new user with the provided credentials,
#              and disables automatic login.

# Display script name and description
echo -e "\033[34m[INFO]\033[0m \033[36mRunning User Management Script\033[0m"

# Username for orangepi, whose password will be changed
USER_ORANGEPI="orangepi"
USER_ROOT="root"

# Check if two arguments (new username and password) are provided
if [ "$#" -ne 2 ]; then
    echo -e "\033[31m[ERROR]\033[0m Usage: $0 <new username> <password>"
    exit 1
fi

# Get the arguments
NEW_USER=$1
PASSWORD=$2

# Change password for the existing user orangepi
if id "$USER_ORANGEPI" &>/dev/null; then
    echo "$USER_ORANGEPI:$PASSWORD" | sudo chpasswd
    echo -e "\033[32m[SUCCESS]\033[0m Password for user $USER_ORANGEPI has been changed to $PASSWORD."
else
    echo -e "\033[31m[ERROR]\033[0m User $USER_ORANGEPI not found."
fi

# Change password for the root user
if id "$USER_ROOT" &>/dev/null; then
    echo "$USER_ROOT:$PASSWORD" | sudo chpasswd
    echo -e "\033[32m[SUCCESS]\033[0m Password for user $USER_ROOT has been changed to $PASSWORD."
else
    echo -e "\033[31m[ERROR]\033[0m User $USER_ROOT not found."
fi

# Create a new user
if id "$NEW_USER" &>/dev/null; then
    echo -e "\033[33m[WARNING]\033[0m User $NEW_USER already exists."
else
    sudo useradd -m -p "$(openssl passwd -1 $PASSWORD)" "$NEW_USER"
    echo -e "\033[32m[SUCCESS]\033[0m User $NEW_USER has been created with password $PASSWORD."
fi

# Disable automatic login
sudo auto_login_cli.sh -d
echo -e "\033[34m[INFO]\033[0m Automatic login has been disabled."
