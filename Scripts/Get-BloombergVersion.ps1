Function Get-BloombergVerion
{
    [CmdletBinding()]
    param (
            # ComputerName
            [Parameter(Position=0)]
            [Alias("cn","pc")]
            [string[]]
            $ComputerName = $env:computername,

            # Path to Wintrv.exe
            [Parameter(Position=1)]
            [String[]]
            [Validateset("c","d","e","f")]
            [Alias("path","location")]
            $InstallPath,

            [bool] $list = $true
    )#Param

    begin {}
    Process {

            foreach($comp in $ComputerName)
            {
                try {
                    $BBergVersion = (Get-itemProperty -path \\$Comp\$($path)`$\Blp\Wintrv\Wintrv.exe -erroraction Stop).VersionInfo
                    if($list -eq $true)
                    {
                        Write-Output  $BBergVersion | Format-List
                    }
                    else {
                        Write-Output $BBergVersion | Format-Table
                    }

            }#Try
            catch { Throw "error! $($_)"}

            }#foreach comp in $ComputerName

    } #process

}#Function