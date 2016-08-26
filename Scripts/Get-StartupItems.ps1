Function Get-StartupItems
{
    [cmdletBinding()]
    param(
        
        $ComputerName = $env:COMPUTERNAME,

        [validateSet("WMI","CIM")]
        $type = "CIM",

        [switch]$GridView

        )#Param

    Switch ($type)
    {
        'CIM'  {
                    try {$StartUpItems = Get-CimInstance -ClassName Win32_StartupCommand -ComputerName $ComputerName -ErrorAction Stop}
                    catch {
                            $oldE = $_.Exception
                            $newE = New-Object -TypeName System.InvalidOperationException('Get-StartupItems: Cannot get Items', $oldE)
                            Throw $newE   
                           }
                    break
                }#CIM
        
        'WMI'  {
                    try {$StartUpItems = Get-WmiObject -ClassName Win32_StartupCommand -ComputerName $ComputerName -ErrorAction Stop}
                    catch {
                            $oldE = $_.Exception
                            $newE = New-Object -TypeName System.InvalidOperationException('Get-StartupItems: Cannot get Items', $oldE)
                            Throw $newE   
                           }
                    break
               
               
               }#WMI
        'default'  {Throw "Error!! Should Not Be here!!"}

    }#Switch

    if($GridView)
    { $StartUpItems | Out-GridView }

    else {  Write-Output -InputObject $StartUpItems }

}#Function Get-StartupItems

