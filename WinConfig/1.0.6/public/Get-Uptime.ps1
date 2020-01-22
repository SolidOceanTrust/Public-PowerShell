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
                ValueFromPipelineByPropertyName = $true,
        Position = 0)]
        [Alias('pc')]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty

    )#param

    Begin{
        $good = @()
        $bad  = @()
        Foreach ($Comp in $ComputerName)
        {
            if((Test-Connection -Count 1 -Quiet -ComputerName $Comp) -eq $true) {
                $good += $comp
            }
            else {
                $bad += $comp
            }
        }
        Write-Verbose "Processing Successfull Computers: $($good)"

    }
    Process
    {
            #Loop Through All the computers and get uptime!
            Foreach ($Computer in $good)
            {
                Try {
                    if ($credential){
                        $WMICall = Get-WmiObject -Query 'Select LastBootupTime FROM Win32_Operatingsystem' -ComputerName $Computer -ErrorAction Stop -Credential $credential
                        Write-Verbose "Sucessfully connected to $Computer via WMI. "    
                    }
                    else {
                        $WMICall = Get-WmiObject -Query 'Select LastBootupTime FROM Win32_Operatingsystem' -ComputerName $Computer -ErrorAction Stop
                        Write-Verbose "Sucessfully connected to $Computer via WMI. "
                    }

                    #
                    $UpTime = $WMICall
                    $UpTime = $UpTime.ConverttoDateTime($UpTime.LastBootUpTime)
                    $TimeSpan = New-TimeSpan -Start $UpTime -ErrorAction SilentlyContinue | Select-Object -Property Days

                    $Object = [PSCustomObject]@{
                        Computer    = $Computer
                        StartTime   = $UpTime
                        Uptime_Days = $($TimeSpan.Days)
                    }
                    Write-Output $Object

                    Remove-Variable -Name Uptime -ErrorAction SilentlyContinue
                    Remove-Variable -Name TimeSpan -ErrorAction SilentlyContinue
                    Remove-Variable -Name Obj -ErrorAction SilentlyContinue
                    Remove-Variable -Name FinalObj -ErrorAction SilentlyContinue
                    Remove-Variable -Name status -ErrorAction SilentlyContinue

                }
                Catch {
                    Write-Error -Exception $_.Exception
                }

            }#foreach
            Foreach ($Computer in $bad) {
                $ObjectBad = [PSCustomObject]@{
                    Computer    = $Computer
                    StartTime   = 'Error'
                    Uptime_Days = 'Error'
                }
                Write-Output $ObjectBad
            }
    }#Process
    End
    {

    }#End

}#Function