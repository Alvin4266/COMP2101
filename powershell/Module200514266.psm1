# Display the report data in a formatted table
$reportData | Format-Table -AutoSize
}

$env:path += ";$home\documents\github\comp2101\powershell"
new-item -path alias:np -value notepad


function welcome {
    Write-Host "Welcome to PowerShell!"
    Write-Host "This is your custom welcome message."
}
welcome

function get-cpuinfo {
    $processors = Get-CimInstance -ClassName CIM_Processor
    foreach ($processor in $processors) {
        "CPU Manufacturer: $($processor.Manufacturer)"
        "CPU Model: $($processor.Name)"
        "Current Speed (MHz): $($processor.CurrentClockSpeed)"
        "Maximum Speed (MHz): $($processor.MaxClockSpeed)"
        "Number of Cores: $($processor.NumberOfCores)"
        "------------------------"
    }
}
get-cpuinfo


# Function to get RAM information
function Get-RAMInfo {
    $ram = Get-CimInstance Win32_PhysicalMemory
    $ramInfo = @()
    foreach ($module in $ram) {
        $ramInfo += New-Object PSObject -Property @{
            'Vendor' = $module.Manufacturer
            'Description' = $module.Caption
            'Size' = "{0:N2} GB" -f ($module.Capacity / 1GB)
            'Bank' = $module.BankLabel
            'Slot' = $module.DeviceLocator
        }
    }
    $ramInfo | Format-Table -AutoSize
    "Total RAM Installed: $($ram | Measure-Object -Property Capacity -Sum | ForEach-Object { '{0:N2} GB' -f ($_.Sum / 1GB) })"
}

# Function to get disk drive information
function Get-DiskDriveInfo {
    $diskDrives = Get-CimInstance CIM_DiskDrive
    $diskInfo = @()
    foreach ($disk in $diskDrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition
        foreach ($partition in $partitions) {
            $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk
            foreach ($logicalDisk in $logicalDisks) {
                $diskInfo += New-Object PSObject -Property @{
                    'Manufacturer' = $disk.Manufacturer
                    'Location' = $partition.DeviceID
                    'Drive' = $logicalDisk.DeviceID
                    'Size(GB)' = [math]::Round($logicalDisk.Size / 1GB, 2)
                }
            }
        }
    }
    $diskInfo | Format-Table -AutoSize
}

# Function to get system information
function Get-SystemInfo {
    $computerSystem = Get-CimInstance Win32_ComputerSystem
    $operatingSystem = Get-CimInstance Win32_OperatingSystem
    $processor = Get-CimInstance Win32_Processor
    $videoController = Get-CimInstance Win32_VideoController

    Write-Host "System Hardware Description: $($computerSystem.Model)"
    Write-Host "Operating System: $($operatingSystem.Caption) $($operatingSystem.Version)"
    Write-Host "Processor: $($processor.Name)"
    Write-Host "RAM Information:"
    Get-RAMInfo
    Write-Host "Disk Drive Information:"
    Get-DiskDriveInfo
    Write-Host "Network Adapter Configuration Report:"
    .\IPConfigurationReport.ps1
    Write-Host "Video Card Information:"
    Write-Host "Vendor: $($videoController.VideoProcessor)"
    Write-Host "Description: $($videoController.Description)"
    Write-Host "Resolution: $($videoController.CurrentHorizontalResolution) x $($videoController.CurrentVerticalResolution)"
}

# Call the main function to generate the report
Get-SystemInfo



function Get-IPConfigurationReport{

# Get a collection of network adapter configuration objects
$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration |
            Where-Object { $_.IPEnabled }

# Create an array to store the report data
$reportData = @()

# Loop through each network adapter configuration object
foreach ($adapter in $adapters) {
    $adapterInfo = @{
        'Adapter Description' = $adapter.Description
        'Index' = $adapter.Index
        'IP Address(es)' = $adapter.IPAddress -join ', '
        'Subnet Mask(s)' = $adapter.IPSubnet -join ', '
        'DNS Domain Name' = $adapter.DNSDomain
        'DNS Server' = $adapter.DNSServerSearchOrder -join ', '
    }
    $reportData += New-Object PSObject -Property $adapterInfo
}
