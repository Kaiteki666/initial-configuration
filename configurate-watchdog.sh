#!/bin/bash

# Script Name: Watchdog Configuration Script
# Description: This script checks for commented RuntimeWatchdogSec and RebootWatchdogSec lines,
#              replaces them if found, or adds them at the end of the file if not.

# Display script name and description
echo -e "\033[34m[INFO]\033[0m Running \033[36mWatchdog Configuration Script\033[0m"

# Define the path to the file
FILE="/etc/systemd/system.conf"

# Function to handle replacing or adding a line
replace_or_add() {
    local search_pattern=$1
    local replace_value=$2

    if sudo grep -q "^$search_pattern" "$FILE"; then
        # Replace the commented line with the new one
        sudo sed -i "s/^$search_pattern.*/$replace_value/" "$FILE"
        echo -e "\033[34m[INFO]\033[0m Line replaced with \033[32m$replace_value\033[0m."
    else
        # If the line is not found, append the new line to the end of the file
        echo "$replace_value" | sudo tee -a "$FILE" > /dev/null
        echo -e "\033[34m[INFO]\033[0m Commented line not found. Added \033[32m$replace_value\033[0m to the end of the file."
    fi
}

# Replace or add RuntimeWatchdogSec=16
replace_or_add "#RuntimeWatchdogSec=" "RuntimeWatchdogSec=16"

# Replace or add RebootWatchdogSec=3min
replace_or_add "#RebootWatchdogSec=" "RebootWatchdogSec=3min"

# Output a success message
echo -e "\033[34m[INFO]\033[0m Changes have been successfully made!"
