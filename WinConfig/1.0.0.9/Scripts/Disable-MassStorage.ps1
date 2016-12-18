Function Disable-MassStorage
{
    Write-Output "This will Disable both READ & WRITE of Mass Storage Devices"

    $Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"

    Write-Output "Disabling Mass Storage"

    Set-ItemProperty $Key -Name "Deny_Read" -Value 1 -Force
    Set-ItemProperty $Key -Name "Deny_Write" -Value 1 -Force

    Write-Output "Mass Storage Disabled!"
}#Function Disable-MassStorage