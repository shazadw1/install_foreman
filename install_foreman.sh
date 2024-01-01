#!/bin/bash

# Install required packages
sudo apt update​

# Set hostname
sudo hostnamectl set-hostname ops.adaplo.co.uk

# Install required packages
sudo apt install -y apt-transport-https wget gpg gnupg ca-certificates

# Download Puppet repository
wget https://apt.puppet.com/puppet7-release-focal.deb


# Add Puppet repository
sudo dpkg -i ./puppet7-release-focal.deb

# Add Foreman repository to system
echo "deb http://deb.theforeman.org/ focal 3.4" | sudo tee /etc/apt/sources.list.d/foreman.list
echo "deb http://deb.theforeman.org/ plugins 3.4" | sudo tee -a /etc/apt/sources.list.d/foreman.list

# Download Foreman GPG keys
wget -q https://deb.theforeman.org/pubkey.gpg -O- | sudo apt-key add -

# Update system package list
sudo apt update

# Install Foreman
sudo apt -y install foreman-installer

# Run Foreman installation
foreman-installer

