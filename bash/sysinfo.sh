#!/bin/bash

# Get hostname and fully qualified domain name
hostname=$(hostname)
fqdn=$(hostname -f)

# Get operating system name and version
os=$(lsb_release -ds)
os_version=$(lsb_release -rs)

# Get the default route IP address
ip_address=$(ip route get 8.8.8.8 | awk '{print $7}')

# Get root filesystem free space in human-friendly format
free_space=$(df -h --output=avail / | tail -n 1)

# Output template with embedded variables
output_template=$(cat <<EOF
Report for $hostname
===============
FQDN: $fqdn
Operating System name and version: $os $os_version
IP Address: $ip_address
Root Filesystem Free Space: $free_space
===============
EOF
)

# Print the formatted output
echo "$output_template"

