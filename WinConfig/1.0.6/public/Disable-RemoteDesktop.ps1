function Disable-RemoteDesktop {
<#
.SYNOPSIS
Disables Remote Desktop Access to machine and Disables Remote Desktop firewall rule

#>
    Write-Output "Disabling Remote Desktop"
	(Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace root\cimv2\terminalservices).SetAllowTsConnections(0) | out-null
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=no | out-null
} #function Disable-RemoteDesktop
