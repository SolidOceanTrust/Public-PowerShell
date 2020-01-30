<#
.SYNOPSIS
    Tests if a computer has a pending reboot
.DESCRIPTION
    Tests if a computer has a pending reboot
.EXAMPLE
    Test-PendingReboot
    Test-PendingReboot -ComputerName server1,server2
.INPUTS
    String[] ComputerName
.OUTPUTS
    String with boolean and Source True if reboot required. False is no reboot required.
.NOTES
    #Adapted from https://gist.github.com/altrive/5329377
    #Based on <http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542>
    # http://ilovepowershell.com/2015/09/10/how-to-check-if-a-server-needs-a-reboot/
#>

function Test-PendingReboot {
    [CmdletBinding()]
    [Alias('testreboot','tpr')]
    param (
        [Alias('pc','comp')]
        [ValidateScript({ (Test-Connection -ComputerName $_ -count 1 -Quiet) -eq $true })]
        [String[]] $computerName = $env:COMPUTERNAME
    )
    # Define scriptBlock to check for a pending reboot
    $rebootSources = {
        if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -erroraction SilentlyContinue) { Write-Output @{Name = $env:ComputerName ; PendingReboot = 'True' ; Source = "Component Based Servicing\RebootPending"} }
        if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -erroraction SilentlyContinue) { Write-Output @{Name = $env:ComputerName ; PendingReboot = 'True' ; Source = "WindowsUpdate\Auto Update\RebootRequired"} }
        if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -erroraction SilentlyContinue) { Write-Output @{Name = $env:ComputerName ; PendingReboot = 'True' ; Source = "PendingFileRenameOperations"} }
        try { 
            $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
            $status = $util.DetermineIfRebootPending()
            if(($null -ne $status) -and $status.RebootPending){
              Write-Output "True,CCM"
            }
          }catch{}
        Write-Output @{Name = $env:ComputerName ; PendingReboot = 'False'}#$false
    }
    
    foreach ($comp in $computerName)
    {
        if ($comp -eq $env:COMPUTERNAME)
        {
            . $rebootSources
        }
        else {
            Invoke-Command -ComputerName $comp -ScriptBlock $rebootSources
        }
    }
}