#!/bin/bash

# Function to display the CPU report
function cpureport {
  echo "CPU Report"
  echo "=============================="

  # Retrieve CPU manufacturer and model
  cpu_manufacturer=$(lshw -class processor | awk -F': ' '/product/ {print $2}')
  cpu_model=$(lshw -class processor | awk -F': ' '/description/ {print $2}')

  # Retrieve CPU architecture
  cpu_architecture=$(lscpu | awk -F': +' '/Architecture/ {print $2}')

  # Retrieve CPU core count
  cpu_cores=$(lscpu | awk -F': +' '/^CPU\(s\)/ {print $2}')

  # Retrieve CPU maximum speed in a human-friendly format
  cpu_max_speed=$(lscpu | awk -F': +' '/^CPU max MHz/ {print $2}')
  cpu_max_speed=$(bc <<< "scale=2; $cpu_max_speed/1000")" GHz"

  # Retrieve sizes of caches (L1, L2, L3) in a human-friendly format
  cache_sizes=$(lscpu | awk -F': +' '/^L[1-3] cache/ {print $2}')
  cache_sizes=$(echo "$cache_sizes" | tr '\n' ', ' | sed 's/,\s$/,/')

  echo "CPU Manufacturer  : $cpu_manufacturer"
  echo "CPU Model         : $cpu_model"
  echo "CPU Architecture  : $cpu_architecture"
  echo "CPU Core Count    : $cpu_cores"
  echo "CPU Max Speed     : $cpu_max_speed"
  echo "Cache Sizes       : $cache_sizes"
}

# Function to display the computer report
function computerreport {
  echo "Computer Report"
  echo "=============================="

  # Retrieve computer manufacturer
  computer_manufacturer=$(dmidecode -s system-manufacturer)

  # Retrieve computer description or model
  computer_model=$(dmidecode -s system-product-name)

  # Retrieve computer serial number
  computer_serial=$(dmidecode -s system-serial-number)

  echo "Computer Manufacturer : $computer_manufacturer"
  echo "Computer Model        : $computer_model"
  echo "Computer Serial Number: $computer_serial"
}

# Function to display the OS report
function osreport {
  echo "OS Report"
  echo "=============================="

  # Retrieve Linux distribution name
  distro=$(lsb_release -ds)

  # Retrieve distribution version
  version=$(lsb_release -rs)

  echo "Linux Distro  : $distro"
  echo "Distro Version: $version"
}

# Function to display the RAM report
function ramreport {
  echo "RAM Report"
  echo "=============================="

  echo "Installed Memory Components:"
  echo "--------------------------------------------------"
  echo "Manufacturer | Model | Size | Speed | Location"
  echo "--------------------------------------------------"

  total_size=0

  # Iterate over each memory component
  while read -r manufacturer model size speed location; do
    echo "$manufacturer | $model | $(human_readable_size $size) | $(human_readable_speed $speed) | $location"
    total_size=$((total_size + size))
  done < <(dmidecode -t memory | awk '/Manufacturer|Part Number|Size|Speed|Locator/ {printf $0 " "; if ($0 ~ /Locator/) print ""}')

  echo "--------------------------------------------------"
  echo "Total Installed RAM: $(human_readable_size $total_size)"
}

# Function to convert size in bytes to human-readable format
function human_readable_size {
  awk -v size=$1 'BEGIN {
    split("B KB MB GB TB", units)
    for (i = 5; size >= 1024 && i > 0; i--)
      size /= 1024
    printf "%.2f %s", size, units[i+1]
  }'
}

# Function to convert speed in MHz to human-readable format
function human_readable_speed {
  awk -v speed=$1 'BEGIN {
    printf "%.2f MHz", speed
  }'
}


# Function to display the Video Report
function videoreport {
  echo "Video Report"
  echo "=============================="

  echo "Video Card/Chipset Information:"
  echo "--------------------------------------------------"
  echo "Manufacturer | Description/Model"
  echo "--------------------------------------------------"

  # Get video card/chipset information
  video_info=$(lshw -C display | awk '/description: VGA|product: / {print $2, $3, $4}')

  if [[ -n "$video_info" ]]; then
    # Display video card/chipset information
    echo "$video_info"
  else
    echo "No video card/chipset information available."
  fi
}

# Function to display the Disk Report
function diskreport {
  echo "Disk Report"
  echo "=============================="

  echo "Installed Disk Drives:"
  echo "--------------------------------------------------"
  echo "Manufacturer | Model | Size | Partition | Mount Point | Filesystem Size | Free Space"
  echo "--------------------------------------------------"

  # Get disk drive information
  disk_info=$(lsblk -bo NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,FSSIZE,FSUSED,FSUSE%,LABEL,MODEL,VENDOR | awk '/disk/ {print $1, $6, $2, $7, $3, $8, $9, $10, $11}')

  if [[ -n "$disk_info" ]]; then
    # Display disk drive information
    echo "$disk_info"
  else
    echo "No disk drive information available."
  fi
}

# Function to display the Network Report
function networkreport {
  echo "Network Report"
  echo "=============================="

  echo "Installed Network Interfaces:"
  echo "-------------------------------------------------------------------------------------------------------------------------"
  echo "Interface | Manufacturer | Model/Description | Link State | Current Speed | IP Addresses | Bridge Master | DNS Servers | Search Domains"
  echo "-------------------------------------------------------------------------------------------------------------------------"

  # Get network interface information
  interface_info=$(ip -o link show | awk -F': ' '{print $2}' | while read -r interface; do
    manufacturer=$(ethtool -i "$interface" 2>/dev/null | awk -F': ' '/^driver/ {print $2}')
    model=$(ethtool -i "$interface" 2>/dev/null | awk -F': ' '/^bus-info/ {print $2}')
    link_state=$(ip -o link show "$interface" | awk '{print $9}')
    speed=$(ethtool "$interface" 2>/dev/null | awk '/Speed/ {print $2}')
    ip_addresses=$(ip -o addr show dev "$interface" | awk '{print $4}')
    bridge_master=$(brctl show | awk -v intf="$interface" '($4 == intf) {print $1}')
    dns_servers=$(nmcli -g IP4.DNS device show "$interface" 2>/dev/null)
    search_domains=$(nmcli -g IP4.DOMAINS device show "$interface" 2>/dev/null)

    echo "$interface | $manufacturer | $model | $link_state | $speed | $ip_addresses | $bridge_master | $dns_servers | $search_domains"
  done)

  if [[ -n "$interface_info" ]]; then
    # Display network interface information
    echo "$interface_info"
  else
    echo "No network interface information available."
  fi
}
