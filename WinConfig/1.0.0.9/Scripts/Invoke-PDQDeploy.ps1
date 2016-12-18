function Invoke-PDQDeploy
{
        <#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    Example of how to use this cmdlet
    .EXAMPLE
    Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $PDQPackagename,
        $PDQServer = 'ussystems02',
        $PDQTarget
     )

    Begin
    {
    }
    Process
    {
        # Connect to the PDQServer
        # Find and validate the pacakage that you want
        # Supply the local computername or remote computername?
        # Push the package to the computer, check for the package to finish?
        # how to verify?

        Invoke-Command -ComputerName $PDQServer -ScriptBlock {

            pdqdeploy.exe deploy -Package $Using:PDQPackagename -Targets $Using:PDQTarget

        }#ScriptBlock

        #Verify
        Write-Output "Waiting 30 Seconds for Deployment to start on $PDQTarget computer"
        Start-Sleep -Seconds 30

        Write-Output "Checking for Deployment on $PDQTarget computer"

        While((Get-Process -Name *PDQDeploy* -ComputerName $PDQTarget) -ne $null)
        {
            "Deployment is still Running..."
            Start-Sleep -Seconds 5

        }#While

        Write-Output "Deployment appears to be complete...Checking Event Log for Message!"

        $StartTime = (Get-Date)
        $FilterHashtable= @{
                                LogName      = "Application"
                                ProviderName = "MsiInstaller"
                                StartTime  = $StartTime.Date
                                ID="1033"
                           }#Filter

        $DeployCheck = Get-WinEvent -ComputerName $PDQTarget -FilterHashtable $FilterHashtable | sort TimeCreated | Select -Last 1

    }
    End
    {
        Write-Output $DeployCheck.Message
    }
}#Function Invoke-PDQDeploy