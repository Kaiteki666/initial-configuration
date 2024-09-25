#!/bin/bash

# Check if a token is passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <token>"
    exit 1
fi

TOKEN=$1

# Update package list and upgrade the system
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
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

# Download the file
wget "https://github.com/cloudflare/cloudflared/releases/download/$LATEST_VERSION/$FILE_NAME"

# Move to the bin directory
sudo mv $FILE_NAME /usr/local/bin/cloudflared

# Make the file executable
sudo chmod +x /usr/local/bin/cloudflared

# Create the service file
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
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable cloudflared-tunnel.service
sudo systemctl start cloudflared-tunnel.service

# Output architecture and version
echo "Cloudflare has been successfully installed!"
echo "Architecture: $ARCHITECTURE"
echo "Cloudflared version: $LATEST_VERSION"

# Additional output to check the installed version
CLOUD_FLARED_VERSION=$(/usr/local/bin/cloudflared --version | grep -Po '\d+\.\d+\.\d+')
echo "Actual cloudflared version: $CLOUD_FLARED_VERSION"
