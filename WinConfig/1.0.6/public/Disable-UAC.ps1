function Disable-UAC {
<#
.SYNOPSIS
Turns on Windows User Access Control

.LINK
http://boxstarter.codeplex.com

#>
    Write-Output "Disabling UAC"
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA  -Value 0 -Force
}#function Disable-UAC