#!/bin/bash

# System Report Script

# Source the function library file
source reportfunctions.sh

# Log file for error messages
log_file="/var/log/systeminfo.log"

# Function to handle error messages
function errormessage {
  local timestamp=$(date +"%Y-%m-%d %T")
  local error_message="$1"
  
  # Save error message with timestamp to the log file
  echo "[$timestamp] $error_message" >> "$log_file"
  
  # Check if running in verbose mode
  if [[ "$verbose" -eq 1 ]]; then
    # Display error message to the user on stderr
    echo "Error: $error_message" >&2
  fi
}

# Function to display help information
function displayhelp {
  echo "System Report Script"
  echo "Usage: systeminfo.sh [OPTIONS]"
  echo "Options:"
  echo "  -h    Display help for the script and exit"
  echo "  -v    Run the script verbosely, showing errors to the user instead of sending them to the logfile"
  echo "  -system    Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
  echo "  -disk    Run only the diskreport"
  echo "  -network    Run only the networkreport"
  exit 0
}

# Check for root permission
if [[ $EUID -ne 0 ]]; then
  errormessage "This script requires root privilege."
  exit 1
fi

# Default behavior: Full system report
run_computer_report=1
run_os_report=1
run_cpu_report=1
run_ram_report=1
run_video_report=1
run_disk_report=1
run_network_report=1
verbose=0

# Process command line options
while getopts ":hvsdn" option; do
  case $option in
    h)  # Help option
      displayhelp
      ;;
    v)  # Verbose option
      verbose=1
      ;;
    s)  # System report option
      run_disk_report=0
      run_network_report=0
      ;;
    d)  # Disk report option
      run_computer_report=0
      run_os_report=0
      run_cpu_report=0
      run_ram_report=0
      run_video_report=0
      run_network_report=0
      ;;
    n)  # Network report option
      run_computer_report=0
      run_os_report=0
      run_cpu_report=0
      run_ram_report=0
      run_video_report=0
      run_disk_report=0
      ;;
    \?) # Invalid option
      errormessage "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

# Run the selected reports

# Computer Report
if [[ $run_computer_report -eq 1 ]]; then
  computerreport
fi

# OS Report
if [[ $run_os_report -eq 1 ]]; then
  osreport
fi

# CPU Report
if [[ $run_cpu_report -eq 1 ]]; then
  cpureport
fi

# RAM Report
if [[ $run_ram_report -eq 1 ]]; then
  ramreport
fi

# Video Report
if [[ $run_video_report -eq 1 ]]; then
  videoreport
fi

# Disk Report
if [[ $run_disk_report -eq 1 ]]; then
  diskreport
fi

# Network Report
if [[ $run_network_report -eq 1 ]]; then
  networkreport
fi

exit 0
