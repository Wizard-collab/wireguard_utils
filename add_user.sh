#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit
fi

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <client_name>"
  exit
fi

# Assign the arguments to variables
server_name=$(cat server_name)
client_name=$1

# Generate a key pair for the client
wg genkey | tee client_privatekey | wg pubkey > client_publickey

# Increment Ip count (USIP)
current_ip=$(cat ${server_name}_used_ip)
echo $current_ip
next_ip=$((current_ip + 1))
echo $next_ip
echo $next_ip > ${server_name}_used_ip

# Create the client configuration file
cat > confs/${client_name}.conf <<EOF

# Please never share this file.

# USER = "$client_name"
# SERVER = "$server_name"

[Interface]
Address = $(cat ${server_name}_ip_map).$next_ip/24
PrivateKey = $(cat client_privatekey)

[Peer]
PublicKey = $(cat ${server_name}_public.key)
Endpoint = $(cat ${server_name}_public_ip):$(cat ${server_name}_port)
AllowedIPs = $(cat ${server_name}_ip_map).0/24
EOF

# Add the client to the server's wg0.conf file
echo "
[Peer]
# $client_name
PublicKey = $(cat client_publickey)
AllowedIPs = $(cat ${server_name}_ip_map).$next_ip/32" >> /etc/wireguard/${server_name}.conf

# Restart the wg-quick@ service
wg-quick down $server_name
wg-quick up $server_name

# Remove the temporary private and public key files
rm client_privatekey
rm client_publickey

