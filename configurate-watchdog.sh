#!/bin/bash

# Script Name: Watchdog Configuration Script
# Description: This script checks for a commented RuntimeWatchdogSec line,
#              replaces it if found, or adds it at the end of the file if not.

# Display script name and description
echo -e "\033[34m[INFO]\033[0m Running \033[36mWatchdog Configuration Script\033[0m"

# Define the path to the file
FILE="/etc/systemd/system.conf"

# Check if the commented line exists in the file
if sudo grep -q '^#RuntimeWatchdogSec=' "$FILE"; then
    # Replace the commented line with the new one
    sudo sed -i 's/^#RuntimeWatchdogSec=.*/RuntimeWatchdogSec=16/' "$FILE"
    echo -e "\033[34m[INFO]\033[0m Line replaced with \033[32mRuntimeWatchdogSec=16\033[0m."
else
    # If the line is not found, append the new line to the end of the file
    echo "RuntimeWatchdogSec=16" | sudo tee -a "$FILE" > /dev/null
    echo -e "\033[34m[INFO]\033[0m Commented line not found. Added \033[32mRuntimeWatchdogSec=16\033[0m to the end of the file."
fi

# Output a success message
echo -e "\033[34m[INFO]\033[0m Changes have been successfully made!"
