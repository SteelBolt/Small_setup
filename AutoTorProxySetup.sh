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
    run_command "sudo apt-get install -y tor proxychains"

    # Check Tor service status (optional)
    run_command "sudo service tor status"

    # Configure Proxychains
    if [ -f /etc/proxychains4.conf ]; then
        sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains4.conf
        sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
        sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains4.conf
        echo -e "\nsocks5  127.0.0.1 9050" | sudo tee -a /etc/proxychains4.conf
    else
        echo "Proxychains configuration file not found!"
        exit 1
    fi

    # Configure DNS resolver (optional - use Cloudflare DNS)
    echo "nameserver 1.1.1.1" | sudo tee /usr/lib/proxychains3/proxyresolv

    # Create symbolic link for the resolver
    run_command "sudo ln -s /usr/lib/proxychains3/proxyresolv /usr/bin/"

    # Restart Tor service
    echo "use sudo service tor restart"
    echo 'An example of how to use the proxychains "proxychains nmap -sCV <ip>"'
    echo "Without running tor and proxychains it will use your real IP!!!"
    echo 'to test with proxychains, try "proxychains firefox"'
}

# Main script execution
install_and_configure_tor
