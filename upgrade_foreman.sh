#!/bin/bash

###DO NOT Upgrade beyond 3.6###

# Set the version variable
version="3.4"

# Shutdown the Foreman instance
echo "Stopping Foreman services..."
sudo systemctl stop apache2 foreman.service foreman.socket dynflow\*

# Update Foreman repository to specified version
echo "Updating Foreman repository to version $version..."
sudo sed -i "s/focal [0-9].[0-9]/focal $version/g" /etc/apt/sources.list.d/foreman.list

# Upgrade all Foreman packages
echo "Upgrading Foreman packages..."
sudo apt-get update
sudo apt-get --only-upgrade install ruby\* foreman\*

# Database migration and cleanup
echo "Performing database migration and cleanup..."
sudo foreman-rake db:migrate
sudo foreman-rake db:seed
sudo foreman-rake tmp:cache:clear
sudo foreman-rake db:sessions:clear

# Optional Step 3 (B) - Reclaim database space
# Uncomment the following line if you want to perform a full database vacuum
su - postgres -c 'vacuumdb --full --dbname=foreman'


# Uncomment the following lines if you want to run the installer in noop mode to see potential changes
sudo foreman-installer --noop --verbose

# Uncomment the following line to apply installer changes
sudo foreman-installer


# Start the Foreman services
echo "Starting Foreman services..."
sudo systemctl start apache2 foreman.service foreman.socket

echo "Foreman upgrade to version $version is complete."
