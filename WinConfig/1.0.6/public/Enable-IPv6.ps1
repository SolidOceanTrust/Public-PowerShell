function Enable-IPv6 {
    $key = “HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\”

    Set-ItemProperty -Path $key -Name “DisabledComponents” -Value 1 -force

    Write-Output "IPv6 is now Enabled. Please restart to complete config"

}#Enable-IPv6