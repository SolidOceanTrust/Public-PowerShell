Function Enable-MassStorage
{
    Write-Output 'This will Enable both READ & WRITE of Mass Storage Devices'

    $Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}'

    Write-Output 'Enabling Mass Storage'

    Set-ItemProperty $Key -Name 'Deny_Read' -Value 0 -Force
    Set-ItemProperty $Key -Name 'Deny_Write' -Value 0 -Force

    Write-Output 'Mass Storage Enabled!'
}#Function Enable-MassStorage