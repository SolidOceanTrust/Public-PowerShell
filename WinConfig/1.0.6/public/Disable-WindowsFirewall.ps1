Function Disable-WindowsFirewall
{
    #PS Version Check
    if($PSVersionTable.PSVersion -ge "4.0")
    {
        Write-Output "Powershell Version 4 or higher decteched, running Native Powershell CMDs"

        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -confirm:$false

        Write-Output "Windows Firewall Disabled!"

    } #if

    else
    {

        Write-Output "Powershell Version 3 or lower decteched, running netsh CMDs"

        netsh advfirewall set allprofiles state off

        Write-Output "Windows Firewall Disabled!"

    }#else


} #Function Disable-WindowsFirewall