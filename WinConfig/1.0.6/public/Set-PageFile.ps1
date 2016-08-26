function Set-PageFile
{
    <#
    .Synopsis
    Sets the Page File
    .DESCRIPTION
    This scritpt will perform the following:
    - Disable OS Auto managed pagefile
    - Remove all existing pagefiles
    - Create a new pagefile on the $DriveLetter param with size of $PageFileSizeMB
    the -AutoSize Parameter will set the page file to 1.5x the amount of RAM
    .EXAMPLE
    Set-PageFile -Driveletter d -Size 100000
    .EXAMPLE
    Set-PageFile -Driveletter d -AutoSize
    #>
    [CmdletBinding()]
    [Alias('setpage')]
    [OutputType([string])]
    Param
    (
        # Drive Letter
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')]
        [ValidateLength(1,1)]
        [string]
        $Driveletter,

        # Page File Size (MB)
        [int]
        $PageFileSizeMB,

        # Auto
        [switch]
        $Auto
    )#Param

    Begin
    {
        #Make sure that a size parameter is applied!!!
        if($PageFileSizeMB -eq $null -and (-not ($auto)))
        {
            Write-Output "No Size or Auto parameter defined. Please supply either -Auto or -PageFileSizeMB to continue"
            Break
        }

        try
        {
            #Check if $DriveLetter is valid
            $QueryDisks = “SELECT * from win32_logicaldisk where DriveType='3'”
            $Disks = Get-CimInstance -Query $QueryDisks -ComputerName $computer -ErrorAction Stop

            $isValidDriveLetter = $Disks | Where-Object {$_.DeviceID -match $driveletter}
            if($isValidDriveLetter)
            {
                Write-Output "a valid drive letter was provided, moving on"
            }#if
            else
            {
                Write-Output "a hard drive with letter $Driveletter was NOT FOUND on this system. Please check the available disks and try again"
                Break
            }

        }#Try
        catch
        {
           Write-Error $_.Exception.Message
        }#Catch
    }#Begin
    Process
    {
        try{
                # Calculate Auto-Sized Page File Size
                $CompSys = Get-CimInstance -ClassName Win32_ComputerSystem
                $Ram = [int]($CompSys.TotalPhysicalMemory / 1GB)
                $AutoPageSizeMB = ($Ram * 1.5) * 1024

                Write-Verbose "Auto Size will be: $AutoPageSizeMB  MB"

                $DriveletterFreeSpaceGB = [int](($Disks | Where-Object {$_.DeviceID -match $driveletter}).FreeSpace /1GB)

                Write-Verbose "FreeSpace(GB) on $Driveletter is: $DriveletterFreeSpaceGB  GB"

                # Double check free space on $DriveLetter!
                # if the Page File Size is bigger than the Free Space, STOP
                # if the (Auto) Page File Size is bigger than the Free Space, STOP
                if(($AutoPageSizeMB / 1024) -gt $DriveletterFreeSpaceGB -or ($PageFileSizeMB / 1024) -gt $DriveletterFreeSpaceGB)
                {
                    Write-Output "Not enough Space on $DriveLetter for a pagefile of that size!"
                    Break
                }

                Pause

                # Disable Auto Pagefile Management
                if($CompSys.AutomaticManagedPagefile -eq "True")
                {
                    Write-Verbose "Disabling Automatically Managed PageFile"
                    $CompSys = Set-CimInstance -Property @{ AutomaticManagedPageFile = $false }
                }#If

                # Delete Page File from C:\
                $PageFile = Get-CimInstance -ClassName Win32_PageFileSetting
                Write-Verbose "Deleting existing PageFile"
                $PageFile | Remove-CimInstance

                # Create Page File on other Drive, Set the Size
                Write-Verbose "Creating new PageFile"

                New-CimInstance -ClassName Win32_PageFileSetting -Property  @{Name= "$("$DriveLetter"):\pagefile.sys"}

                if($Auto)
                {
                    Write-Verbose "Creating new Auto-Sized PageFile of Size: $AutoPageSizeMB"
                    $NewAutoPageFile = Get-CimInstance -ClassName Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $($DriveLetter):'"
                    $NewAutoPageFile | Set-CimInstance -Property @{InitialSize = $AutoPageSizeMB; MaximumSize = $AutoPageSizeMB }
                }#if
                else
                {
                    $NewPageFile = Get-CimInstance -ClassName Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $($DriveLetter):'"
                    $NewPageFile | Set-CimInstance -Property @{InitialSize = $PageFileSizeMB; MaximumSize = $PageFileSizeMB }
                }#else

            }#try
        catch
        {
            Write-Error $_.Exception.Message
        }

    }#Process
    End
    {
        Clear-Host
        Write-Output "All done with the page file!"
        Get-CimInstance -ClassName Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $($DriveLetter):'"
    }#End

}# function Set-PageFile