#!/bin/bash

# Check if the user has root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run it as root."
  exit 1
fi

# System Description Section
echo "System Description"
echo "------------------"

# Computer Manufacturer
manufacturer=$(dmidecode -s system-manufacturer 2>/dev/null)
if [[ -n "$manufacturer" ]]; then
  echo "Manufacturer: $manufacturer"
else
  echo "Manufacturer: Data unavailable"
fi

# Computer Model
model=$(dmidecode -s system-product-name 2>/dev/null)
if [[ -n "$model" ]]; then
  echo "Model: $model"
else
  echo "Model: Data unavailable"
fi

# Computer Serial Number
serial=$(dmidecode -s system-serial-number 2>/dev/null)
if [[ -n "$serial" ]]; then
  echo "Serial Number: $serial"
else
  echo "Serial Number: Data unavailable"
fi

# CPU Information Section
echo
echo "CPU Information"
echo "---------------"

# CPU Manufacturer and Model
cpu_info=$(lshw -class processor 2>/dev/null | awk -F ': ' '/product/{print $2}')
if [[ -n "$cpu_info" ]]; then
  echo "Manufacturer and Model: $cpu_info"
else
  echo "Manufacturer and Model: Data unavailable"
fi

# CPU Architecture
architecture=$(lshw -class processor 2>/dev/null | awk -F ': ' '/capabilities/{print $2}')
if [[ -n "$architecture" ]]; then
  echo "Architecture: $architecture"
else
  echo "Architecture: Data unavailable"
fi

# CPU Core Count
core_count=$(lscpu | awk '/^CPU\(s\):/{print $2}')
if [[ -n "$core_count" ]]; then
  echo "Core Count: $core_count"
else
  echo "Core Count: Data unavailable"
fi

# CPU Maximum Speed
max_speed=$(lscpu | awk '/^CPU max MHz:/{print $4}')
if [[ -n "$max_speed" ]]; then
  echo "Maximum Speed: $max_speed MHz"
else
  echo "Maximum Speed: Data unavailable"
fi

# CPU Cache Sizes
cache_sizes=$(lscpu | awk '/^L[1-3] cache:/{print $3}')
if [[ -n "$cache_sizes" ]]; then
  echo "Cache Sizes:"
  echo "$cache_sizes"
else
  echo "Cache Sizes: Data unavailable"
fi

# Operating System Information Section
echo
echo "Operating System Information"
echo "---------------------------"

# Linux Distro
distro=$(lsb_release -ds 2>/dev/null)
if [[ -n "$distro" ]]; then
  echo "Linux Distro: $distro"
else
  echo "Linux Distro: Data unavailable"
fi

# Distro Version
version=$(lsb_release -rs 2>/dev/null)
if [[ -n "$version" ]]; then
  echo "Version: $version"
else
  echo "Version: Data unavailable"
fi
