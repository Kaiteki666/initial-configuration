#!/bin/bash

# Script Name: Cloudflare Tunnel Installation
# Description: This script installs Cloudflare Tunnel, configures it with the provided token,
#              and sets it up as a service to run on startup.

# Display script name and description
echo -e "\033[34m[INFO]\033[0m Running \033[36mCloudflare Tunnel Installation Script\033[0m"

# Check if a token is passed
if [ "$#" -ne 1 ]; then
    echo -e "\033[31m[ERROR]\033[0m Usage: $0 <token>"
    exit 1
fi

TOKEN=$1

# Update package list and upgrade the system
echo -e "\033[34m[INFO]\033[0m Updating package list and upgrading the system..."
sudo apt update
sudo apt upgrade -y

# Get the latest version of cloudflared
LATEST_VERSION=$(curl -s https://api.github.com/repos/cloudflare/cloudflared/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
ARCHITECTURE=$(uname -m)

# Determine architecture
if [[ "$ARCHITECTURE" == "x86_64" ]]; then
    FILE_NAME="cloudflared-linux-amd64"
elif [[ "$ARCHITECTURE" == "armhf" ]]; then
    FILE_NAME="cloudflared-linux-armhf"
elif [[ "$ARCHITECTURE" == "aarch64" ]]; then
    FILE_NAME="cloudflared-linux-arm64"
else
    echo -e "\033[31m[ERROR]\033[0m Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

# Download the file
echo -e "\033[34m[INFO]\033[0m Downloading cloudflared version $LATEST_VERSION for architecture $ARCHITECTURE..."
wget "https://github.com/cloudflare/cloudflared/releases/download/$LATEST_VERSION/$FILE_NAME"

# Move to the bin directory
echo -e "\033[34m[INFO]\033[0m Moving cloudflared to /usr/local/bin..."
sudo mv $FILE_NAME /usr/local/bin/cloudflared

# Make the file executable
echo -e "\033[34m[INFO]\033[0m Making cloudflared executable..."
sudo chmod +x /usr/local/bin/cloudflared

# Create the service file
echo -e "\033[34m[INFO]\033[0m Creating systemd service file..."
sudo bash -c "cat > /etc/systemd/system/cloudflared-tunnel.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Environment=NODE_ENV=production
ExecStart=/usr/local/bin/cloudflared tunnel --no-autoupdate run --token $TOKEN
StandardOutput=journal
StandardError=inherit
Restart=always
RestartSec=10s
User=root

[Install]
WantedBy=multi-user.target
EOF"

# Reload the systemd configuration
echo -e "\033[34m[INFO]\033[0m Reloading systemd configuration..."
sudo systemctl daemon-reload

# Enable and start the service
echo -e "\033[34m[INFO]\033[0m Enabling and starting the cloudflared service..."
sudo systemctl enable cloudflared-tunnel.service
sudo systemctl start cloudflared-tunnel.service

# Output architecture and version
echo -e "\033[32m[SUCCESS]\033[0m Cloudflare has been successfully installed!"
echo -e "\033[34m[INFO]\033[0m Architecture: $ARCHITECTURE"
echo -e "\033[34m[INFO]\033[0m Cloudflared version: $LATEST_VERSION"

# Additional output to check the installed version
CLOUD_FLARED_VERSION=$(/usr/local/bin/cloudflared --version | grep -Po '\d+\.\d+\.\d+')
echo -e "\033[34m[INFO]\033[0m Actual cloudflared version: $CLOUD_FLARED_VERSION"
