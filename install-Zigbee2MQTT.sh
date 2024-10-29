#!/bin/bash

# Script Name: Zigbee2MQTT Installation
# Description: This script sets up Zigbee2MQTT, installs dependencies, builds the app,
#              configures it, and sets it up as a service to run on startup.
#              If Zigbee2MQTT is already installed, it will remove the previous installation
#              and related files before reinstalling.

# Display script name and description
echo -e "\033[34m[INFO]\033[0m Running \033[36mZigbee2MQTT Installation Script\033[0m"

# Check if both login, password, and base_topic are provided
if [ "$#" -ne 3 ]; then
    echo -e "\033[31m[ERROR]\033[0m Usage: $0 <mqtt_user> <mqtt_password> <base_topic>"
    exit 1
fi

MQTT_USER=$1
MQTT_PASSWORD=$2
BASE_TOPIC=$3

# Check if Zigbee2MQTT is already installed
if [ -d "/opt/zigbee2mqtt" ]; then
    echo -e "\033[34m[INFO]\033[0m Zigbee2MQTT is already installed. Removing previous installation..."
    
    # Stop the service if running
    echo -e "\033[34m[INFO]\033[0m Stopping Zigbee2MQTT service..."
    sudo systemctl stop zigbee2mqtt.service 2>/dev/null
    
    # Disable the service
    echo -e "\033[34m[INFO]\033[0m Disabling Zigbee2MQTT service..."
    sudo systemctl disable zigbee2mqtt.service 2>/dev/null
    
    # Remove Zigbee2MQTT directory
    echo -e "\033[34m[INFO]\033[0m Removing Zigbee2MQTT files..."
    sudo rm -rf /opt/zigbee2mqtt
    
    # Remove the systemd service file
    echo -e "\033[34m[INFO]\033[0m Removing Zigbee2MQTT systemd service file..."
    sudo rm /etc/systemd/system/zigbee2mqtt.service
    
    # Reload systemd to apply changes
    echo -e "\033[34m[INFO]\033[0m Reloading systemd daemon..."
    sudo systemctl daemon-reload
    
    echo -e "\033[34m[INFO]\033[0m Previous installation of Zigbee2MQTT has been removed successfully."
else
    echo -e "\033[34m[INFO]\033[0m No previous installation of Zigbee2MQTT found."
fi

# Check Node.js and npm versions
echo -e "\033[34m[INFO]\033[0m Checking Node.js and npm versions..."
node_version=$(node --version)
npm_version=$(npm --version)
echo -e "\033[34m[INFO]\033[0m Node.js version: $node_version"
echo -e "\033[34m[INFO]\033[0m npm version: $npm_version"

if [[ "$node_version" < "v18" ]] || [[ "$npm_version" < "9" ]]; then
    echo -e "\033[31m[ERROR]\033[0m Node.js (v18+) and npm (v9+) are required."
    exit 1
fi

# Create Zigbee2MQTT directory and set permissions
echo -e "\033[34m[INFO]\033[0m Creating Zigbee2MQTT directory..."
sudo mkdir -p /opt/zigbee2mqtt
sudo chown -R ${USER}: /opt/zigbee2mqtt

# Clone the Zigbee2MQTT repository
echo -e "\033[34m[INFO]\033[0m Cloning Zigbee2MQTT repository..."
git clone --depth 1 https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt

# Install dependencies
echo -e "\033[34m[INFO]\033[0m Installing Zigbee2MQTT dependencies..."
cd /opt/zigbee2mqtt
npm ci || npm ci --maxsockets 1

# Build the app
echo -e "\033[34m[INFO]\033[0m Building Zigbee2MQTT..."
npm run build

# Copy and configure configuration.yaml
echo -e "\033[34m[INFO]\033[0m Copying and configuring configuration.yaml..."
cp /opt/zigbee2mqtt/data/configuration.example.yaml /opt/zigbee2mqtt/data/configuration.yaml
cat <<EOF > /opt/zigbee2mqtt/data/configuration.yaml
# Home Assistant integration (MQTT discovery) 
homeassistant: false  

# Enable the frontend, runs on port 8080 by default 
frontend:  
  port: 8085 

# MQTT settings 
mqtt: 
  base_topic: $BASE_TOPIC 
  server: mqtt://localhost:1883 

  user: $MQTT_USER 
  password: $MQTT_PASSWORD 

# Serial settings 
serial: 
  port: /dev/ttyACM0 

# Advanced settings 
advanced: 
  network_key: GENERATE 
  pan_id: GENERATE 
  ext_pan_id: GENERATE 
EOF

echo -e "\033[32m[SUCCESS]\033[0m Zigbee2MQTT configuration complete!"

# Set up Zigbee2MQTT as a systemd service
echo -e "\033[34m[INFO]\033[0m Creating Zigbee2MQTT systemd service..."
sudo bash -c "cat > /etc/systemd/system/zigbee2mqtt.service <<EOF
[Unit] 
Description=zigbee2mqtt 
After=network.target 

[Service] 
Environment=NODE_ENV=production 
ExecStart=/usr/bin/npm run start 
WorkingDirectory=/opt/zigbee2mqtt 
StandardOutput=null 
StandardError=inherit 
Restart=always 
RestartSec=10s 
User=${USER} 

[Install] 
WantedBy=multi-user.target 
EOF"

# Enable and start the Zigbee2MQTT service
echo -e "\033[34m[INFO]\033[0m Enabling and starting Zigbee2MQTT service..."
sudo systemctl daemon-reload
sudo systemctl enable zigbee2mqtt.service
sudo systemctl start zigbee2mqtt.service

echo -e "\033[32m[SUCCESS]\033[0m Zigbee2MQTT has been successfully installed and started!"
