#!/bin/bash

# Function to install plugins
install_plugins() {
    echo "Installing plugins..."

    # Install Foreman Remote Execution plugin
    foreman-installer --enable-foreman-plugin-remote-execution

    # Install Smart Proxy Remote Execution SSH plugin
    foreman-installer --enable-foreman-proxy-plugin-remote-execution-ssh

    # Install Snapshot plugin
    foreman-installer --enable-foreman-plugin-snapshot-managemen

}

# Function to generate a key for Smart Proxy
generate_proxy_key() {
    echo "Generating SSH key for Smart Proxy..."

    # Check if .ssh exists and is a file, then remove it
    rm -f ~foreman-proxy/.ssh
    mkdir ~foreman-proxy/.ssh
    chown foreman-proxy ~foreman-proxy/.ssh
    sudo -u foreman-proxy ssh-keygen -f ~foreman-proxy/.ssh/id_rsa_foreman_proxy -N ''


    #Restarting services
    systemctl restart apache2.service
    sudo systemctl restart foreman.service
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

    # Test the renewal process
    echo "Testing certificate renewal process..."
    sudo certbot renew --dry-run
    
    #Set Cron to auto renew certs
    (sudo crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet") | sudo crontab -

    # Check if the Let's Encrypt files exist and update Foreman configurations
    local cert_file="/etc/letsencrypt/live/$HOSTNAME/cert.pem"
    local chain_file="/etc/letsencrypt/live/$HOSTNAME/chain.pem"
    local key_file="/etc/letsencrypt/live/$HOSTNAME/privkey.pem"
    

    [[ -f "$cert_file" ]] && sudo foreman-installer --foreman-server-ssl-cert "$cert_file" || echo "Certificate file not found."
    [[ -f "$chain_file" ]] && sudo foreman-installer --foreman-server-ssl-chain "$chain_file" || echo "Chain file not found."
    [[ -f "$key_file" ]] && sudo foreman-installer --foreman-server-ssl-key "$key_file" || echo "Key file not found."
    foreman-installer --foreman-proxy-foreman-ssl-ca  /etc/ssl/certs/ca-certificates.crt
    foreman-installer --puppet-server-foreman-ssl-ca  /etc/ssl/certs/ca-certificates.crt
    
    
}

# Main script execution
echo "Starting script..."

# Call functions
#install_plugins
generate_proxy_key
update_ssl


echo "Script execution completed."
