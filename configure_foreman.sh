#!/bin/bash

# Function to install plugins
install_plugins() {
    echo "Installing plugins..."

    # Install Foreman Remote Execution plugin
    sudo apt-get install ruby-foreman-remote-execution

    # Install Smart Proxy Remote Execution SSH plugin
    sudo apt-get install ruby-smart-proxy-remote-execution-ssh
}

# Function to generate a key for Smart Proxy
generate_proxy_key() {
    echo "Generating SSH key for Smart Proxy..."

    # Resolve the home directory of the foreman-proxy user
    proxy_home=$(getent passwd foreman-proxy | cut -d: -f6)

    # Check if .ssh exists and is a file, then remove it
    if [ -f "$proxy_home/.ssh" ]; then
        echo "Found a file named .ssh, removing it..."
        rm -f "$proxy_home/.ssh"
    fi

    # Check if the .ssh directory exists, if not create it
    if [ ! -d "$proxy_home/.ssh" ]; then
        echo "Creating .ssh directory..."
        mkdir "$proxy_home/.ssh"
        chown foreman-proxy:foreman-proxy "$proxy_home/.ssh"
    else
        echo ".ssh directory already exists."
    fi

    # Generate SSH key without a passphrase, if it doesn't already exist
    if [ ! -f "$proxy_home/.ssh/id_rsa_foreman_proxy" ]; then
        sudo -u foreman-proxy ssh-keygen -f "$proxy_home/.ssh/id_rsa_foreman_proxy" -N ''
    else
        echo "SSH key already exists."
    fi
}

# Main script execution
echo "Starting script..."

# Function to update SSL
update_ssl() {

    # Get the actual hostname of the system
    HOSTNAME=$(hostname)

    echo "Updating SSL..."
    
    # Install Certbot and its Apache plugin
    sudo apt-get install -y certbot python3-certbot-apache

    # Run Certbot command to enable HTTPS for Foreman
    certbot_command="certbot --apache -d $HOSTNAME --redirect --hsts"
    log "Running Certbot command: $certbot_command"
    $certbot_command

    # Check the exit status of Certbot command
    if [ $? -ne 0 ]; then
        log "Error: Certbot command failed. Please check Certbot logs for details."
        exit 1
    fi

    log "Certbot command completed successfully."

    # Check if the Let's Encrypt files exist and update Foreman configurations
    local cert_file="/etc/letsencrypt/live/$HOSTNAME/cert.pem"
    local chain_file="/etc/letsencrypt/live/$HOSTNAME/chain.pem"
    local key_file="/etc/letsencrypt/live/$HOSTNAME/privkey.pem"
    local ca_bundle="/etc/ssl/certs/ca-bundle.crt"

    [[ -f "$cert_file" ]] && sudo foreman-installer --foreman-server-ssl-cert "$cert_file" || echo "Certificate file not found."
    [[ -f "$chain_file" ]] && sudo foreman-installer --foreman-server-ssl-chain "$chain_file" || echo "Chain file not found."
    [[ -f "$key_file" ]] && sudo foreman-installer --foreman-server-ssl-key "$key_file" || echo "Key file not found."
    [[ -f "$ca_bundle" ]] && sudo foreman-installer --foreman-proxy-foreman-ssl-ca "$ca_bundle" --puppet-server-foreman-ssl-ca "$ca_bundle" || echo "CA bundle file not found."
}

# Main script execution
echo "Starting script..."

# Call functions
install_plugins
generate_proxy_key
update_ssl
generate_proxy_key

echo "Script execution completed."
