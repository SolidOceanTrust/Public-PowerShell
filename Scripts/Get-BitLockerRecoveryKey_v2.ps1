<#
.Synopsis
   Gets BitLocker Recovery Key
.DESCRIPTION
   Long description
.EXAMPLE
   Get-BLKey -comp
.EXAMPLE
   
#>
Function Get-BLKey
{
    [CmdletBinding()]
    [Alias("blk","bitlockerkey","blkey")]
    [OutputType([psobject])]
    param
    (
        # Get Computer Object
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string[]]$computer = $env:COMPUTERNAME,

        [Parameter()] #Parameter Set = "OU"
        $ADSearchBase
    )

    Import-Module ActiveDirectory
    
    foreach ($c in $computer)
    {
        try {
                $ComputerObject = Get-ADComputer -Filter {Name -eq $c} -ErrorAction Stop
                $BitLockerObjects = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $ComputerObject.DistinguishedName -Properties 'msFVE-RecoveryPassword'
                                
                    $properties = @{
                                        'ComputerName' = $ComputerObject.Name
                                        'BitLockerKey' = $BitLockerObjects."msFVE-RecoveryPassword"          
                                   }#Properties
                
                    $object = New-Object -TypeName psobject -Property $properties
                
                Write-Output -InputObject $object
            }#try
        catch {
                Write-Error -Exception $_
              }#catch
    }#foreach
}