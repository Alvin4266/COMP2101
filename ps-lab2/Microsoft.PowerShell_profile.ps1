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
