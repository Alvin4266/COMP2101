#!/bin/bash
#
# This script displays system information for a Linux machine in sections.

# Check for root privilege
if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires root privileges. Please run it as root or using sudo."
  exit 1
fi

# Function to check if a command failed and display an error message
check_command_status() {
  local command_name="$1"
  local exit_code="$2"

  if [ "$exit_code" -ne 0 ]; then
    echo "Error: Failed to execute '$command_name' command."
    exit 1
  fi
}

# System Description
####################
echo "System Description"
echo "=================="

# Computer manufacturer
computer_manufacturer=$(dmidecode -s system-manufacturer)
check_command_status "dmidecode" "$?"

# Computer description or model
computer_description=$(dmidecode -s system-product-name)
check_command_status "dmidecode" "$?"

# Computer serial number
computer_serial=$(dmidecode -s system-serial-number)
check_command_status "dmidecode" "$?"

# Print system description
echo "Manufacturer  : $computer_manufacturer"
echo "Description   : $computer_description"
echo "Serial Number : $computer_serial"
echo

# CPU Information
#################
echo "CPU Information"
echo "==============="

# CPU information from lshw command
cpu_info=$(lshw -class processor)
check_command_status "lshw" "$?"

# Iterate over each CPU
cpu_count=$(echo "$cpu_info" | grep -c "product:")
for ((cpu_index = 0; cpu_index < cpu_count; cpu_index++)); do
  cpu_section=$(echo "$cpu_info" | awk -v index="$cpu_index" '/product:/ { p=1 } p && !--index { print; exit }')

  # CPU manufacturer and model
  cpu_manufacturer=$(echo "$cpu_section" | awk -F': ' '/vendor:/ { print $2 }')
  cpu_model=$(echo "$cpu_section" | awk -F': ' '/product:/ { print $2 }')

  # CPU architecture
  cpu_arch=$(echo "$cpu_section" | awk -F': ' '/capabilities:/ { print $2 }')

  # CPU core count
  cpu_cores=$(echo "$cpu_section" | awk -F': ' '/cores:/ { print $2 }')

  # CPU maximum speed
  cpu_max_speed=$(echo "$cpu_section" | awk -F': ' '/capacity:/ { print $2 }')

  # CPU caches
  cpu_caches=$(echo "$cpu_section" | awk -F': ' '/cache:/ { print $2 }')

  # Print CPU information
  echo "CPU $((cpu_index + 1))"
  echo "Manufacturer  : $cpu_manufacturer"
  echo "Model         : $cpu_model"
  echo "Architecture  : $cpu_arch"
  echo "Cores         : $cpu_cores"
  echo "Max Speed     : $cpu_max_speed"
  echo "Caches        : $cpu_caches"
  echo
done

# Operating System Information
##############################
echo "Operating System Information"
echo "============================"

# Linux distribution
linux_distro=$(lsb_release -ds)
check_command_status "lsb_release" "$?"

# Distro version
distro_version=$(lsb_release -rs)
check_command_status "lsb_release" "$?"

# Print OS information
echo "Distribution  : $linux_distro"
echo "Version       : $distro_version"
echo

# RAM Information
#################
echo "RAM Information"
echo "==============="

# Installed memory components
ram_info=$(lshw -class memory)
check_command_status "lshw" "$?"

# Total installed RAM size
total_ram=$(echo "$ram_info" | awk -F': ' '/size:/ { sum+=$2 } END { printf "%.2f GB\n", sum/1024/1024 }')

# Print RAM information
echo "Total Installed RAM : $total_ram"
echo

# Table headers
echo "Manufacturer | Model | Size | Speed | Location"
echo "-----------------------------------------------"

# Table rows
echo "$ram_info" | awk -F': ' '/bank:/ { printf "%-12s | %-5s | %-4s | %-5s | %-8s\n", $2, $4, $6, $8, $10 }'
echo

# Disk Storage
##############
echo "Disk Storage"
echo "============"

# Installed disk drives
disk_info=$(lsblk -dno NAME,SIZE,MODEL)
check_command_status "lsblk" "$?"

# Table headers
echo "Manufacturer | Model | Size | Partition | Mount Point | Filesystem Size | Free Space"
echo "-----------------------------------------------------------------------------------"

# Table rows
while read -r disk_row; do
  disk_name=$(echo "$disk_row" | awk '{ print $1 }')
  disk_size=$(echo "$disk_row" | awk '{ print $2 }')
  disk_model=$(echo "$disk_row" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')

  partitions=$(lsblk -dno NAME,MOUNTPOINT,FSTYPE,SIZE -r /dev/"$disk_name" | awk -v disk_name="$disk_name" '{ printf "%s %s %s %s\n", disk_name, $1, $2, $4 }')

  while read -r partition_row; do
    partition_name=$(echo "$partition_row" | awk '{ print $1 }')
    partition_mount=$(echo "$partition_row" | awk '{ print $2 }')
    partition_fs=$(echo "$partition_row" | awk '{ print $3 }')
    partition_size=$(echo "$partition_row" | awk '{ print $4 }')

    echo "$disk_model | $disk_size | $partition_name | $partition_mount | $partition_fs | $partition_size"
  done <<<"$partitions"
done <<<"$disk_info"

exit 0
