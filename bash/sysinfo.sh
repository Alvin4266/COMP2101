#!/bin/bash

# Script to display information about the computer

# Display the Fully-Qualified Domain Name (FQDN)
echo -n "FQDN: "
hostname

echo "Host Information:"
# Display information about the system using hostnamectl
hostnamectl

echo "IP Addresses:"
# Display the IP addresses excluding the ones starting with 127
hostname -I | grep -v '^127'

echo "Root Filesystem Status:"
# Display the status of the root filesystem using df
df -h / | awk 'NR==2 {print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}'

# End of script
