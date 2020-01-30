Function Set-PowerPlan
{
    # https://technet.microsoft.com/en-us/library/hh824902.aspx
    # http://blogs.technet.com/b/heyscriptingguy/archive/2010/08/30/find-active-power-plan-on-remote-servers-by-using-powershell.aspx

    [CmdletBinding()]
    Param
        (
            # PowerPlan Param help description
            [Parameter(Mandatory=$true,Position=0)]
            [ValidateSet("Balanced","High_Performance","Power_Saver")]
            [String]$PowerPlan
        )

        #Convert Plan Names into GUIDS
        Switch($PowerPlan)
        {
            'Balanced' {$Guid = "381b4222-f694-41f0-9685-ff5bb260df2e"}
            'High_Performance' {$Guid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"}
            'Power_Saver' {$Guid = "a1841308-3541-4fab-bc81-f71556f20b4a"}
        }#Switch

        try {
              powercfg /SETACTIVE $Guid
              Write-Output "PowerPlan Chagned to: $PowerPlan "
              Get-PowerPlan
             }# try

        catch{"Error: Not a valid powerplan scheme. Please use ' powercfg /l ' to get the correct powerplan scheme name"}

} #Function Set-PowerPlan