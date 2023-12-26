#!/bin/bash

# Get the system hostname
HOSTNAME=$(hostname)

# Function to set up nightly backups and rclone configuration
setup_nightly_backups() {
    sudo tee "/etc/cron.daily/foreman_backup" > /dev/null <<EOL
#!/bin/bash

# Set the backup base directory
backup_base="/var/lib/foreman/backups"

# Create the backup base directory if it doesn't exist
if [ ! -d "\$backup_base" ]; then
    mkdir -p "\$backup_base"
fi

# Create a timestamp for the backup
timestamp=\$(date +"%Y%m%d_%H%M%S")
date_folder=\$(date +"%Y%m%d")

# Create the backup date folder if it doesn't exist
if [ ! -d "\$backup_base/\$date_folder" ]; then
    mkdir -p "\$backup_base/\$date_folder"
fi

# Backup Foreman database using foreman-rake
foreman-rake db:dump FILE="\$backup_base/\$date_folder/foreman_db_\$timestamp.sql"

# Compress the backup files
tar -czf "\$backup_base/\$date_folder/foreman_backup_\$timestamp.tar.gz" \
    "\$backup_base/\$date_folder/foreman_db_\$timestamp.sql"

# Remote directory on OneDrive
remote_directory="onedrive:/backups/$HOSTNAME/\$date_folder"

# Log file for rclone copy
rclone_log="/var/log/rclone_backup.log"

# Add timestamp to the log file
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting rclone copy." >> "\$rclone_log"

# Upload the backup files to OneDrive using rclone with logging
rclone copy "\$backup_base/\$date_folder" "\$remote_directory" --log-file "\$rclone_log"

# Check rclone exit status and log result
if [ \$? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rclone copy completed successfully." >> "\$rclone_log"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Rclone copy failed. See '\$rclone_log' for details." >&2
fi

# Remove old backups (keep the last 7 days)
find "\$backup_base" -name "foreman_backup_*.tar.gz" -mtime +7 -exec rm {} \;
EOL

    # Make the backup script executable
    sudo chmod +x "/etc/cron.daily/foreman_backup"
}

# Function to install & configure rclone
install_rclone() {
    sudo -v ; curl https://rclone.org/install.sh | sudo bash
    sudo rclone config
}

# Call functions
setup_nightly_backups
install_rclone

