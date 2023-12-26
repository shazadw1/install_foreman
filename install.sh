#!/bin/bash

# Define the path where the scripts are located
SCRIPT_PATH="/opt/install_foreman"

# Function to display the menu
show_menu() {
    echo "1) Install Foreman"
    echo "2) Upgrade Foreman"
    echo "3) Confgure Foreman"
    echo "4) Backup Foreman"
    echo "5) Restore Foreman"
    echo "q) Quit"
}

# Function to read the user's choice
read_choice() {
    local choice
    read -p "Enter choice [1-4]: " choice
    case $choice in
        1) bash "$SCRIPT_PATH/install_foreman.sh";;
        2) bash "$SCRIPT_PATH/upgrade_foreman.sh";;
        3) bash "$SCRIPT_PATH/configure_foreman.sh";;
        4) bash "$SCRIPT_PATH/backup_foreman.sh";;
        3) bash "$SCRIPT_PATH/restore_foreman.sh";;
        q) exit 0;;
        *) echo "Error: Invalid option. Please try again.";;
    esac
}

# Main loop
while true
do
    show_menu
    read_choice
done
