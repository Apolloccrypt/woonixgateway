#!/bin/bash

# Exit on any error
set -e

# Update and install required packages
sudo apt-get update
sudo apt-get install -y tor iptables-persistent

# Configure Tor
sudo bash -c 'cat <<EOF > /etc/tor/torrc
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
TransListenAddress 0.0.0.0
DNSPort 53
DNSListenAddress 0.0.0.0
EOF'

# Configure iptables rules
sudo bash -c 'cat <<EOF > /etc/iptables.up.rules
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p tcp --syn -j REDIRECT --to-ports 9040
-A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 53
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF'

# Apply iptables rules at startup
sudo bash -c 'cat <<EOF > /etc/network/if-pre-up.d/iptables
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.up.rules
EOF'

# Make the script executable
sudo chmod +x /etc/network/if-pre-up.d/iptables

# Apply the iptables rules now
sudo iptables-restore < /etc/iptables.up.rules

# Restart Tor service
sudo systemctl restart tor

echo "Tor gateway setup is complete. Configure your other VMs to use this VM as their gateway."
