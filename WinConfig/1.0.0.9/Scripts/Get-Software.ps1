function Get-Software
{
    [CmdletBinding()]
    [Alias('software','soft')]
    param
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                    Position=0
                   )]
        [Alias("pc","cn")]
        [ValidateScript({((Test-Connection -quiet -Count 1 -ComputerName $_) -eq $true)})]
        [string[]] 
        $computername = 'localhost',

        [Parameter(Position=1)]
        [string]
        $Name ='*',
        
        [Parameter(Position=2)]
        [string]
        $UninstallString ='*'

        
    )

    $Failed = @()

    Foreach ($computer in $computername)
    {
        try{
                # We know the computer pings, does it have PSRemoting enabled?
                Test-WSMan -ComputerName $computer -ErrorAction Stop | Out-Null

                # OK, All good, let's run the query!
                Invoke-Command -ErrorAction SilentlyContinue -ComputerName $computer -ScriptBlock {

                        $keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

                        Get-ItemProperty -Path $keys |
                        Where-Object { $_.DisplayName } |
                        Select-Object -Property DisplayName, DisplayVersion, UninstallString |
                        Where-Object { $_.DisplayName -like $Using:Name } |
                        Where-Object { $_.UninstallString -like $Using:UninstallString }

                }#ScriptBlock

            } #try

        catch
            {
                $failed += $computer
             }#Catch

    }#Foreach ($computer in $computername)

    if($Failed)
    {Write-Host -ForegroundColor Red "These Computers Failed to be contacted (PS Remoting): "$Failed }


}# Get-Software