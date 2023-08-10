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

# Display the report data in a formatted table
$reportData | Format-Table -AutoSize
