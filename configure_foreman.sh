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
    rm -f "$proxy_home/.ssh"

    # Check if the .ssh directory exists, if not create it
     mkdir "$proxy_home/.ssh"
     # Generate SSH key without a passphrase, if it doesn't already exist
    sudo -u foreman-proxy ssh-keygen -f "$proxy_home/.ssh/id_rsa_foreman_proxy" -N ''
}

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

    # Check if the Let's Encrypt files exist and update Foreman configurations
    local cert_file="/etc/letsencrypt/live/$HOSTNAME/cert.pem"
    local chain_file="/etc/letsencrypt/live/$HOSTNAME/chain.pem"
    local key_file="/etc/letsencrypt/live/$HOSTNAME/privkey.pem"
   # local ca_bundle="/etc/ssl/certs/ca-bundle.crt"

    [[ -f "$cert_file" ]] && sudo foreman-installer --foreman-server-ssl-cert "$cert_file" || echo "Certificate file not found."
    [[ -f "$chain_file" ]] && sudo foreman-installer --foreman-server-ssl-chain "$chain_file" || echo "Chain file not found."
    [[ -f "$key_file" ]] && sudo foreman-installer --foreman-server-ssl-key "$key_file" || echo "Key file not found."
    #[[ -f "$ca_bundle" ]] && sudo foreman-installer --foreman-proxy-foreman-ssl-ca "$ca_bundle" --puppet-server-foreman-ssl-ca "$ca_bundle" || echo "CA bundle file not found."
}

# Main script execution
echo "Starting script..."

# Call functions
install_plugins
generate_proxy_key
update_ssl
generate_proxy_key

echo "Script execution completed."
