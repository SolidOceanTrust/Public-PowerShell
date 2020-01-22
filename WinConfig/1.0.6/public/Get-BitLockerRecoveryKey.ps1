<#
.Synopsis
   Gets BitLocker Recovery Key
.DESCRIPTION
   Grabs the BitLocker Recovery key from AD. Accepts OU or computer name
.EXAMPLE
   Get-BLKey -computer mypc
.EXAMPLE
   Get-BLKey -ADSearchBase "OU=Computers,OU=Site,DC=Domain,DC=corp"
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
                   ParameterSetName='Computer Parameter Set',
                   Position=0)]
        [string[]]$computer = $env:COMPUTERNAME,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName='AD Parameter Set',
                   Position=0)]
        [string[]]$ADSearchBase
    )

    Import-Module ActiveDirectory
    
    If( ( $PSBoundParameters.ContainsKey(‘ADSearchBase’)) )
    {
        Write-Verbose " AD Parameter Set chosen "
        foreach ($ADOU in $ADSearchBase)
        {
           try {
                    #$ComputerObject = Get-ADComputer -SearchBase $ADOU -Filter 'Enabled -eq $True"' -ErrorAction Stop
                    $BitLockerObjects = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $ADOU -Properties 'msFVE-RecoveryPassword' -ErrorAction Stop

                    foreach ($BitLockerObject in $BitLockerObjects)
                    {
                            $properties = @{
                                        'ComputerName' = ($BitLockerObject.DistinguishedName.Split(",")[1]).Replace("CN=","")
                                        'BitLockerKey' = ($BitLockerObject."msFVE-RecoveryPassword")
                                    }#Properties
                   
                    $object = New-Object -TypeName psobject -Property $properties
                
                    Write-Output -InputObject $object

                    }#foreach BitLockerObject

                }#try
            catch {
                    Write-Error -Exception $_
                    }#catch

        }#foreach
        

    }

    else {
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
         
         }#else

}#Funtion