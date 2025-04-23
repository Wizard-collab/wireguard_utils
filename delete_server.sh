#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit
fi

server_name=$(cat server_name)
wg-quick down $server_name
rm /etc/wireguard/"$server_name".conf

script_path=$(realpath "$0")
parent_dir=$(dirname "$script_path")
rm -R $parent_dir
