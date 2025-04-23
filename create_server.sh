#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit
fi

# Check if the correct number of arguments are provided
if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <wireguard server name> <ip map ex : 10.0.0> <port> <public ip> <dir>"
  exit
fi

# Assign the arguments to variables
server_name=$1
ip_map=$2
port=$3
public_ip=$4
dir=$5

mkdir -p $dir
mkdir -p "${dir}/confs"

echo "$server_name" >> "${dir}/server_name"
echo "$public_ip" >> "${dir}/${server_name}_public_ip"
echo "$port" >> "${dir}/${server_name}_port"
echo "$ip_map" >> "${dir}/${server_name}_ip_map"
echo "1" >> "${dir}/${server_name}_used_ip"

# Generate a key pair for the client
wg genkey | tee "${dir}/${server_name}_private.key" | wg pubkey > "${dir}/${server_name}_public.key"

cat > /etc/wireguard/"$server_name".conf <<EOF

[Interface]
Address = $ip_map.0/24
PrivateKey = $(cat "${dir}/${server_name}_private.key")
ListenPort = $port
EOF

wg-quick up $server_name

cp -iv "add_user.sh" "${dir}/add_user.sh"
cp -iv "delete_server.sh" "${dir}/delete_server.sh"