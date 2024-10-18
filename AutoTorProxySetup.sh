#!/bin/bash

# Function to run a command and handle errors
run_command() {
    local cmd="$1"
    if ! eval "$cmd"; then
        echo "Error running command '$cmd'"
        exit 1
    fi
}

# Function to install and configure Tor and Proxychains
install_and_configure_tor() {
    # Update package lists and install Tor and Proxychains
    run_command "sudo apt-get update"
    run_command "sudo apt-get install -y tor proxychains4"
    
    # Start and enable Tor service
    run_command "sudo systemctl start tor"
    run_command "sudo systemctl enable tor"
    
    # Check Tor service status
    if ! systemctl is-active --quiet tor; then
        echo "Error: Tor service is not running. Exiting."
        exit 1
    fi
    
    # Backup original Proxychains configuration
    sudo cp /etc/proxychains4.conf /etc/proxychains4.conf.bak
    
    # Configure Proxychains
    if [ -f /etc/proxychains4.conf ]; then
        sudo sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains4.conf
        sudo sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
        sudo sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains4.conf
        echo -e "\nsocks5  127.0.0.1 9050" | sudo tee -a /etc/proxychains4.conf
    else
        echo "Proxychains configuration file not found!"
        exit 1
    fi
    
    echo "Tor and Proxychains have been installed and configured."
    echo "To use Proxychains, prefix your commands with 'proxychains4'. For example:"
    echo "proxychains4 firefox"
    echo "To revert changes, run this script with the '--revert' option."
}

# Function to revert changes
revert_changes() {
    run_command "sudo apt-get remove -y tor proxychains4"
    run_command "sudo apt-get autoremove -y"
    if [ -f /etc/proxychains4.conf.bak ]; then
        sudo mv /etc/proxychains4.conf.bak /etc/proxychains4.conf
    fi
    echo "Changes have been reverted."
}

if [ "$1" == "--revert" ]; then
    revert_changes
else
    install_and_configure_tor
fi

# To revert changes: sudo bash AutoTorProxySetup.sh --revert
