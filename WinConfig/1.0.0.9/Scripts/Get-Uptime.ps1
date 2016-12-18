Function Get-Uptime
{
    <#
            .Synopsis
            Returns the Uptime of the remote PC via CIM or WMI
            .DESCRIPTION
            Returns the Uptime of the remote PC via CIM or WMI
            .EXAMPLE
            Get-Uptime -ComputerName localhost
            .EXAMPLE
            Get-Uptime -ComputerName dc1,localhost,mdt1 -WMI
            .INPUTS
            ComputerName (can take array)
            .OUTPUTS
            Object with Computer,Date,etc
    #>

    [CmdletBinding()]
    [Alias('uptime','upt')]
    [OutputType([String])]
    Param(
        [Parameter(Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $false,
        Position = 0)]
        [Alias('pc')]
        [String[]]$ComputerName = $env:COMPUTERNAME

        #[Switch]$WMI = $false
    )#param

    Begin{}
    Process
    {
            #Test to make sure that each computer is reachable
            # if yes, determine uptime via WMI/CIM method(s). set $Status to OK, if Cannot get uptime $status="Error"
            # if not, set $status to "Offline" and dump

            #Loop Through All the computers and get uptime!
            Foreach ($Computer in $ComputerName)
            {

                #Test Ping and CIM connection(s) to remote machine, if sucessful, use CIM to get uptime. If not, then for it to use WMI
                # if computer cannot be reached, break the loop with output!
                if((Test-Connection -Count 1 -Quiet -ComputerName $Computer) -eq $true)
                {

                    if ( ($ConnectionTestCIM = (Get-CimInstance -Query 'Select LastBootupTime FROM Win32_Operatingsystem' -ComputerName $Computer -ErrorAction SilentlyContinue).LastBootupTime) -ne $null)
                    {
                        Write-Verbose "Sucessfully connected to $Computer via CIM. "
                        Write-Verbose -Message $ConnectionTestCIM
                        $ConnectionMethod = 'CIM'

                    }
                    elseif( ($ConnectionTestWMI = (Get-WmiObject -Query 'Select LastBootupTime FROM Win32_Operatingsystem' -ComputerName $Computer -ErrorAction SilentlyContinue)) -ne $null)
                    {
                        Write-Verbose "Sucessfully connected to $Computer via WMI. "
                        Write-Verbose -Message $ConnectionTestWMI
                        $ConnectionMethod = 'WMI'
                    }
                    else
                    {
                        Write-Output -InputObject "Bad Computer!!!"
                        $Status = 'ERROR'

                        # Connection Method Done, Now to build Data!
                        $UptimeProperties  = @{
                            'Computer'         = $Computer
                            'StartTime'        = '?'
                            'Days'             = '?'
                            'Status'           = $Status
                            'MightNeedPatched' = $false
                        } #$UptimeProperties

                        $Obj = New-Object -TypeName psobject -Property $UptimeProperties
                        $Obj = $Obj | Select-Object -Property Computer, StartTime, Status

                        Write-Output -InputObject $Obj
                        Remove-Variable -Name Obj -ErrorAction SilentlyContinue
                        Remove-Variable -Name Status -ErrorAction SilentlyContinue
                    }#else

                #All Good From here! Computer is pingable and responds to WMI/CIM. Let's build our data and write some objects
                switch($ConnectionMethod)
                {
                    'WMI'
                     {
                            $UpTime = $ConnectionTestWMI
                            $UpTime = $UpTime.ConverttoDateTime($UpTime.LastBootUpTime)
                            $TimeSpan = New-TimeSpan -Start $UpTime -ErrorAction SilentlyContinue | Select-Object -Property Days
                            $Status = 'OK'
                     }

                     'CIM'
                     {

                        $UpTime = $ConnectionTestCIM
                        $TimeSpan = New-TimeSpan -Start $UpTime -ErrorAction SilentlyContinue | Select-Object -Property Days
                        $Status = 'OK'
                      }

                }#Switch

                  #Connection Method Done, Now to build Data!
                  $UptimeProperties  = @{
                            'Computer'    = $Computer
                            'StartTime'   = $UpTime
                            'Uptime'   = $TimeSpan.Days
                            'Status'  = $Status
                            'MightNeedPatched' = $false
                        } #$UptimeProperties

                        $Obj = New-Object -TypeName psobject -Property $UptimeProperties

                        if($Obj.Uptime -gt 30)
                        {
                            $Obj.MightNeedPatched = $true
                            $FinalObj = $Obj | Select-Object -Property Computer, StartTime ,@{label='Uptime (Days)';expression={$_.Uptime}}, Status, MightNeedPatched
                        }
                        else
                        {
                            $FinalObj = $Obj | Select-Object -Property Computer, StartTime ,@{label='Uptime (Days)';expression={$_.Uptime}}, Status
                        }#else

                        Write-Output -InputObject $FinalObj | Format-Table -AutoSize

                        Remove-Variable -Name Uptime -ErrorAction SilentlyContinue
                        Remove-Variable -Name TimeSpan -ErrorAction SilentlyContinue
                        Remove-Variable -Name Obj -ErrorAction SilentlyContinue
                        Remove-Variable -Name FinalObj -ErrorAction SilentlyContinue
                        Remove-Variable -Name status -ErrorAction SilentlyContinue

                }#if((Test-Connection -Count 1 -Quiet -ComputerName $Computer) -eq $true)
                else
                {
                    $Status = 'OFFLINE'

                    # Connection Method Done, Now to build Data!
                    $UptimeProperties  = @{
                        'ComputerName'      = $Computer
                        'StartTime'     = '?'
                        'Days'          = '?'
                        'Uptime'        = '?'
                        'Status'        = $Status
                        'MightNeedPatched' = $false
                    } #$UptimeProperties

                    $Obj = New-Object -TypeName psobject -Property $UptimeProperties
                    #Clean it up:
                    $Obj = $Obj | Select-Object -Property ComputerName, StartTime, Uptime, Status

                    Write-Output -InputObject $Obj
                    Remove-Variable -Name Obj -ErrorAction SilentlyContinue
                    Remove-Variable -Name Status -ErrorAction SilentlyContinue

                    Break

                }#Else

            }#foreach
    }#Process
    End
    {

    }#End

}#Function