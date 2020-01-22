Function Enable-WindowsFirewall
{
    #PS Version Check
    if($PSVersionTable.PSVersion -ge "4.0")
    {
        Write-Output "Powershell Version 4 or higher decteched, running Native Powershell CMDs"

        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -confirm:$false

        Write-Output "Windows Firewall Enabled!"

    } #if

    else
    {

        Write-Output "Powershell Version 3 or lower decteched, running netsh CMDs"

        netsh advfirewall set allprofiles state on

        Write-Output "Windows Firewall Enabled!"

    }#else

} #Function Enable-WindowsFirewall