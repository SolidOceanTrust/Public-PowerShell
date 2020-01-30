function Get-UAC {
<#
.SYNOPSIS
Checks if User Access Control is turned on

.LINK
http://boxstarter.codeplex.com

#>
    $uac=Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA
    return $uac.EnableLUA -eq 1
}#function Get-UAC