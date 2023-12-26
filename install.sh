#!/bin/bash

# Define the path where the scripts are located
SCRIPT_PATH="/opt/install_foreman"

# Function to display the menu
show_menu() {
    echo "1) Install Foreman"
    echo "2) Upgrade Foreman"
    echo "3) Secure Foreman"
    echo "4) Quit"
}

# Function to read the user's choice
read_choice() {
    local choice
    read -p "Enter choice [1-4]: " choice
    case $choice in
        1) bash "$SCRIPT_PATH/install_foreman.sh";;
        2) bash "$SCRIPT_PATH/upgrade_foreman.sh";;
        3) bash "$SCRIPT_PATH/secure_foreman.sh";;
        4) exit 0;;
        *) echo "Error: Invalid option. Please try again.";;
    esac
}

# Main loop
while true
do
    show_menu
    read_choice
done
