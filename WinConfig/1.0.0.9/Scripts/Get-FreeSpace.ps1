function Get-FreeSpace
{
    <#
    .Synopsis
       Gets Free Diskspace
    .DESCRIPTION
       Connects to localhost (by default) or a list of PCs. Tries to connect first with CIM, then WMI
    .EXAMPLE
       Get-FreeSpace
    .EXAMPLE
       Get-Freespace -computername Server1,Server2,Server3
    .INPUTS
       ComputerName, String[]
    .OUTPUTS
       PSObject
    .NOTES
    #>

    [CmdletBinding()]
    [Alias('space')]
    [OutputType([PSObject])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        <#[ValidateScript({
                         #Make Sure every computer user supplies is at, minimmum ping-able. We will worry about CIM/WMI later
                         ((Test-Connection -ComputerName $_ -Quiet -Count 1) -eq $true)
                        })]
         #>
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=1)]
        [ValidateSet("WMI","CIM")]
        $Method = "CIM"



    )

    Begin
    {
        $ComputersFail = @()

    }#Begin
    Process
    {
        # Query for Disks (WMI/CIM)
        $QueryDisks = “SELECT * from win32_logicaldisk where DriveType='3'”
        $QueryMountPoints = "Select * FROM Win32_Volume WHERE DriveLetter=NULL AND Capacity!=NULL AND Label!='System Reserved'"

        Foreach($computer in $ComputerName)
        {
            Switch($Method)
            {
                "CIM"
                {
                    ###Free space via CIM
                    # Get all the fixed Disks
                    Try {
                            $CIMDisks = Get-CimInstance -Query $QueryDisks -ComputerName $computer -ErrorAction Stop
                            $MountPoints = Get-CimInstance -Query $QueryMountPoints -ComputerName $Computer -ErrorAction Stop


                            # Get all the free space per each disk
                            foreach($CIMDisk in $CIMDisks)
                            {
                                #Build a hashtable and PS Object, Write it to the output
                                $Properties = @{
                                                    'Computer'    = $computer
                                                    'DriveLetter' = $CIMDisk.DeviceID
                                                    'VolumeName'  = $CIMDisk.VolumeName
                                                    'FreeSpace'   = "{0:n2} GB" -f ($CIMDisk.FreeSpace / 1GB)
                                                    'TotalSize'   = "{0:n2} GB" -f ($CIMDisk.Size / 1GB)
                                                    'PercentFree' = "{0:n0} %" -f (($CIMDisk.FreeSpace / $CIMDisk.Size) * 100)
                                                    'IsMountPoint' = "NO"
                                               }#Properties

                                $ObjectCIM = New-Object -TypeName psobject -Property $Properties

                                $ObjectCIM = $ObjectCIM | Select-Object Computer,DriveLetter,VolumeName,FreeSpace,TotalSize,PercentFree,IsMountPoint

                                Write-Output $ObjectCIM
                                Remove-Variable Properties -Force -ErrorAction SilentlyContinue
                                Remove-Variable ObjectCIM -Force -ErrorAction SilentlyContinue
                            }#Foreach

                            # Get all the free space per each mount point
                            foreach($MountPoint in $MountPoints)
                            {
                                #Build a hashtable and PS Object, Write it to the output
                                 $Properties = @{
                                                        'Computer'         = $computer
                                                        'Label'            = $MountPoint.Label
                                                        'MountPointName'   = $MountPoint.Name
                                                        'FreeSpace'        = "{0:n2} GB" -f ($MountPoint.FreeSpace / 1GB)
                                                        'TotalSize'        = "{0:n2} GB" -f ($MountPoint.Capacity / 1GB)
                                                        'PercentFree'      = "{0:n0} %" -f (($MountPoint.FreeSpace / $MountPoint.Capacity) * 100)
                                                        'IsMountPoint'     = "YES"
                                                   }#Properties

                                $ObjectMountPoint = New-Object -TypeName psobject -Property $Properties

                                $ObjectMountPoint = $ObjectMountPoint | Select-Object Computer,Label,MountPointName,FreeSpace,TotalSize,PercentFree,IsMountPoint

                                Write-Output $ObjectMountPoint
                                Remove-Variable Properties -Force -ErrorAction SilentlyContinue
                                Remove-Variable ObjectMountPoint -Force -ErrorAction SilentlyContinue

                               } #foreach($MountPoint in $MountPoints)

                        } #Try

                 catch {
                             Write-Verbose "unable to Connect to $computer !! Check Access/Permissions"
                             $ComputersFail += $computer
                        } #Catch

                 }#CIM

                "WMI"
                {
                    Try {
                            $WMIDisks = Get-WmiObject -Query $QueryDisks -ComputerName $Computer -ErrorAction Stop
                            $MountPoints = Get-WmiObject -Query $QueryMountPoints -ComputerName $Computer -ErrorAction Stop



                            # Get all the free space per each disk
                            foreach($WMIDisk in $WMIDisks)
                            {
                                #Build a hashtable and PS Object, Write it to the output
                                $Properties = @{
                                                    'Computer'    = $computer
                                                    'DriveLetter' = $WMIDisk.DeviceID
                                                    'VolumeName'  = $WMIDisk.VolumeName
                                                    'FreeSpace'   = "{0:n2} GB" -f ($WMIDisk.FreeSpace / 1GB)
                                                    'TotalSize'   = "{0:n2} GB" -f ($WMIDisk.Size / 1GB)
                                                    'PercentFree' = "{0:n0} %" -f (($WMIDisk.FreeSpace / $WMIDisk.Size) * 100)
                                                    'IsMountPoint' = "NO"
                                               }#Properties

                                $ObjectWMI = New-Object -TypeName psobject -Property $Properties

                                $ObjectWMI = $ObjectWMI | Select-Object Computer,DriveLetter,VolumeName,FreeSpace,TotalSize,PercentFree,IsMountPoint

                                Write-Output $ObjectWMI
                                Remove-Variable Properties -Force -ErrorAction SilentlyContinue
                                Remove-Variable ObjectWMI -Force -ErrorAction SilentlyContinue

                            }#foreach ($WMIDisk in $WMIDisks)

                            # Get all the free space per each mount point
                            foreach($MountPoint in $MountPoints)
                            {
                                #Build a hashtable and PS Object, Write it to the output
                                $Properties = @{
                                                    'Computer'         = $computer
                                                    'Label'            = $MountPoint.Label
                                                    'MountPointName'   = $MountPoint.Name
                                                    'FreeSpace'        = "{0:n2} GB" -f ($MountPoint.FreeSpace / 1GB)
                                                    'TotalSize'        = "{0:n2} GB" -f ($MountPoint.Capacity / 1GB)
                                                    'PercentFree'      = "{0:n0} %" -f (($MountPoint.FreeSpace / $MountPoint.Capacity) * 100)
                                                    'IsMountPoint'     = "YES"
                                               }#Properties

                                $ObjectMountPoint = New-Object -TypeName psobject -Property $Properties

                                $ObjectMountPoint = $ObjectMountPoint | Select-Object Computer,Label,MountPointName,FreeSpace,TotalSize,PercentFree,IsMountPoint

                                Write-Output $ObjectMountPoint
                                Remove-Variable Properties -Force -ErrorAction SilentlyContinue
                                Remove-Variable ObjectMountPoint -Force -ErrorAction SilentlyContinue

                             } #foreach($MountPoint in $MountPoints)

                           }# try
                  catch {
                             Write-Verbose "unable to Connect to $computer !! Check Access/Permissions"
                             $ComputersFail += $computer
                         } #catch
                }#WMI

            }#Switch $Method


         }# Foreach($computer in $ComputerName)

    }#Process

    End
    {
        if($ComputersFail)
        { Write-Output "The following Hosts had errors: $ComputersFail  " }

    }#End
}#function Get-FreeSpace