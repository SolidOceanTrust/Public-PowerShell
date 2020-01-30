function Get-Software
{
    [CmdletBinding()]
    [Alias('software','soft')]
    param
    (
        [Parameter(Position = 0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true
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
        $UninstallString ='*',

        [switch]
        $filter
    )
    
    $final = @()
    $Failed = @()
    $Keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

    Foreach ($computer in $computername)
    {
        $result = $null
        try{
                if($computer -eq 'localhost')
                {
                  Write-Verbose "Local Computer"
                  $result = Get-ItemProperty -Path $keys -ErrorAction SilentlyContinue | Where-Object { `
                    $_.DisplayName -and `
                    $_.DisplayName -like "$($Name)*" -and `
                    $_.UninstallString -like $UninstallString} `
                   | Select-Object -Property DisplayName, DisplayVersion, UninstallString 
                
                   foreach ($item in $result) {
                        $output = [PSCustomObject]@{
                            Name            = $item.DisplayName
                            Version         = $item.DisplayVersion
                            UninstallString = $item.UninstallString
                            Computername    = $computer
                        }
                        $final += $output
                   }                   
                   
                   Write-Output -InputObject $final
                   if($filter) {
                       Write-Output -InputObject $( $final | Select-Object Name,Version,ComputerName )
                   }
                   else { Write-Output -InputObject $final }                

                }# if($computer -eq 'localhost')
                else
                {
                    Write-Verbose "Remote Computer"
                    # We know the computer pings, does it have PSRemoting enabled?
                    $null = Test-WSMan -ComputerName $computer -ErrorAction Stop

                    # OK, All good, let's run the query!
                    $result = Invoke-Command -ErrorAction SilentlyContinue -ComputerName $computer -ArgumentList $keys -ScriptBlock {

                          Get-ItemProperty -Path $using:keys | Where-Object { `
                          $_.DisplayName -and `
                          $_.DisplayName -like "$($using:Name)*" -and `
                          $_.UninstallString -like $Using:UninstallString} `
                         | Select-Object -Property DisplayName, DisplayVersion, UninstallString 
                    
                    }#ScriptBlock
                    foreach ($item in $result) {
                        $output = [PSCustomObject]@{
                            Name            = $item.DisplayName
                            Version         = $item.DisplayVersion
                            UninstallString = $item.UninstallString
                            Computername    = $computer
                        }
                        Write-Output -InputObject $output    
                    }
                    
                    if($filter) {
                        Write-Output -InputObject $( $output | Select-Object Name,Version,ComputerName )
                    }
                    else { Write-Output -InputObject $output }

                }#Else
            
            } #try
        catch
            {
                $failed += $computer
             }#Catch
        
    }#Foreach ($computer in $computername)

    if($Failed)
    {Write-Host -ForegroundColor Red "These Computers Failed to be contacted (PS Remoting): "$Failed }

}# Get-Software