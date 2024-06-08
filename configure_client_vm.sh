#!/bin/bash

# Exit on any error
set -e

# Variables
TOR_GATEWAY_IP=<TOR_GATEWAY_IP>  # Vervang dit door het IP-adres van de Tor-gateway VM
INTERFACE_NAME=eth0  # Vervang dit door de juiste netwerkinterface indien nodig

# Configure Netplan to use the Tor gateway
sudo bash -c "cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    ${INTERFACE_NAME}:
      dhcp4: no
      addresses:
        - 192.168.1.102/24  # Vervang dit door het statische IP-adres van deze VM
      gateway4: ${TOR_GATEWAY_IP}
      nameservers:
        addresses:
          - ${TOR_GATEWAY_IP}
EOF"

# Apply the Netplan configuration
sudo netplan apply

echo "The client VM has been configured to use the Tor gateway at ${TOR_GATEWAY_IP}."
