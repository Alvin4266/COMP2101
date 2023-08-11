param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

function Get-HardwareInfo {
    $hardware = Get-CimInstance -ClassName Win32_ComputerSystem
    Write-Host "System Hardware Description: $($hardware.Manufacturer), $($hardware.Model)"
}

function Get-OSInfo {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Host "Operating System: $($os.Caption) $($os.Version)"
}

function Get-CPUInfo {
    $cpu = Get-CimInstance -ClassName Win32_Processor
    Write-Host "Processor: $($cpu.Name)"
}

function Get-RAMInfo {
    $ram = Get-CimInstance -ClassName Win32_PhysicalMemory
    Write-Host "RAM Information:"
    foreach ($module in $ram) {
        Write-Host "  Vendor: $($module.Manufacturer)"
        Write-Host "  Description: $($module.PartNumber)"
        Write-Host "  Size: $($module.Capacity / 1GB) GB"
        Write-Host "  Bank: $($module.BankLabel)"
        Write-Host "  Slot: $($module.DeviceLocator)"
    }
}

function Get-DiskInfo {
    $diskdrives = Get-CimInstance -ClassName Win32_DiskDrive
    Write-Host "Disk Drive Information:"
    foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk
            foreach ($logicaldisk in $logicaldisks) {
                Write-Host "  Vendor: $($disk.Manufacturer)"
                Write-Host "  Model: $($disk.Model)"
                Write-Host "  Drive: $($logicaldisk.DeviceID)"
                Write-Host "  Size: $($logicaldisk.Size / 1GB) GB"
                Write-Host "  Free Space: $($logicaldisk.FreeSpace / 1GB) GB"
                Write-Host "  Percentage Free: $([math]::Round(($logicaldisk.FreeSpace / $logicaldisk.Size) * 100, 2))%"
            }
        }
    }
}

function Get-NetworkInfo {
    Write-Host "Network Adapter Configuration Report:"
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

    $reportData = @()
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

    $reportData | Format-Table -AutoSize
}

function Get-VideoInfo {
    $video = Get-CimInstance -ClassName Win32_VideoController
    Write-Host "Video Card Information:"
    foreach ($v in $video) {
        Write-Host "  Vendor: $($v.AdapterCompatibility)"
        Write-Host "  Description: $($v.Description)"
        Write-Host "  Resolution: $($v.CurrentHorizontalResolution) x $($v.CurrentVerticalResolution)"
    }
}

if ($System) {
    Get-HardwareInfo
    Get-OSInfo
    Get-CPUInfo
    Get-RAMInfo
    Get-VideoInfo
} elseif ($Disks) {
    Get-DiskInfo
} elseif ($Network) {
    Get-NetworkInfo
} else {
    Get-HardwareInfo
    Get-OSInfo
    Get-CPUInfo
    Get-RAMInfo
    Get-DiskInfo
    Get-NetworkInfo
    Get-VideoInfo
}
