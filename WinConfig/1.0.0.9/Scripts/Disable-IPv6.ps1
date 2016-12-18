function Disable-IPv6 {
    $key = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"

    Set-ItemProperty -Path $key -Name 'DisabledComponents' -Value 0xff -force

    Write-Output "IPv6 is now Disabled. Please restart to complete config"

}#Disable-IPv6