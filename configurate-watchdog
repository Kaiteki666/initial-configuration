#!/bin/bash

# Define the path to the file
FILE="/etc/systemd/system.conf"

# Check if the commented line exists in the file
if sudo grep -q '^#RuntimeWatchdogSec=' "$FILE"; then
    # Replace the commented line with the new one
    sudo sed -i 's/^#RuntimeWatchdogSec=.*/RuntimeWatchdogSec=16/' "$FILE"
    echo "Line replaced with RuntimeWatchdogSec=16."
else
    # If the line is not found, append the new line to the end of the file
    echo "RuntimeWatchdogSec=16" | sudo tee -a "$FILE" > /dev/null
    echo "Commented line not found. Added RuntimeWatchdogSec=16 to the end of the file."
fi

# Output a success message
echo "Changes have been successfully made!"
