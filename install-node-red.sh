#!/bin/bash

# Check if username and password are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Please provide a username and a password as arguments."
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# Store the username and password in variables
USERNAME="$1"
PASSWORD="$2"

# 1. Execute Node-RED installation
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi  --restart --no-init

# 2. Start Node-RED to create the settings.js file
echo "Starting Node-RED to initialize files..."
node-red-start &
sleep 15  # Wait for Node-RED to create the settings
node-red-stop

# 3. Generate password hash
HASHED_PASSWORD=$(echo "$PASSWORD" | node-red admin hash-pw | grep -o '\$.*')

# 4. Update the settings.js file
SETTINGS_FILE="$HOME/.node-red/settings.js"
echo "Checking the settings file at path: $SETTINGS_FILE"

if [ -f "$SETTINGS_FILE" ]; then
    echo "settings.js file found. Starting to replace the commented block..."

    # Replace the commented block with fully uncommented text and remove the extra commented bracket
    sed -i '/\/\/adminAuth: {/,+7c\    adminAuth: {\n        type: "credentials",\n        users: [{\n            username: "'"$USERNAME"'",\n            password: "'"$HASHED_PASSWORD"'",\n            permissions: "*"\n        }]\n    },' "$SETTINGS_FILE"

    # Replace context storage
    sed -i '/\/\/contextStorage: {/,+5c\
contextStorage: {\n  default: "memoryOnly",\n  memoryOnly: { module: '\''memory'\'' },\n        file: { module: '\''localfilesystem'\'',\n                config: {\n                        flushInterval: 300\n                        },\n              },\n   },' "$SETTINGS_FILE"

    echo "settings.js file successfully updated."
else
    echo "Error: settings.js file not found!"
fi

echo "Node-RED installed and configured with user $USERNAME and the provided password."

# 5. Install extensions for Node-RED
echo "Installing extensions for Node-RED..."
cd $HOME/.node-red && \
npm install node-red-contrib-aedes && \
npm install node-red-contrib-blynk-iot && \
npm install node-red-contrib-cron-plus && \
npm install node-red-contrib-homekit-bridged && \
npm install node-red-contrib-modbus && \
npm install node-red-contrib-simple-gate && \
npm install node-red-contrib-zigbee2mqtt-devices && \
npm install node-red-node-ping && \
npm install node-red-node-serialport

echo "Extensions successfully installed."

# 6. Enable Node-RED service to start on boot
sudo systemctl enable nodered.service
