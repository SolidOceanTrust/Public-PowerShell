
<#

.AUTHOR Bnabel

.COMPANYNAME Taconic Capital Advisors

.COPYRIGHT 2016

.TAGS BitLocker Systems HelpDesk Tools

.LICENSEURI http://intranet/systems/BitLocker

.PROJECTURI http://intranet/systems/BitLocker

.ICONURI http://intranet/systems/BitLocker/Icon.ico

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Intial version uploaded. Single function. Added some aliaes

.DESCRIPTION
 Checks BitLocker Configuration on local & remote systems
#>
Function Get-BitLockerStatus
{

    [CmdletBinding()]
    [Alias("gbs","bitlocker","blstatus")]
    [OutputType([PSObject])]
    param(
            [String[]]$ComputerName = $env:COMPUTERNAME
    )#Param

Begin {
    #Check Computer Online?
    $good = @()
    $bad  = @()
    $multiDrive = @()
    $singleDrive = @()
    foreach($comp in $ComputerName)
    {
        #test
        if(Test-Connection -ComputerName $comp -Count 1 -Quiet)
        {
            $good += $comp
        }#if
        else { $bad += $comp } #else
    }#foreach
}#begin

Process {

            foreach ($comp in $good)
            {
                $BDEOutput = manage-bde -Computername $comp -status

                # Computer has a single drive
                if($BDEOutput.Length -le 24)
                {
                        $Properties = @{
                            'ComputerName'   = $($Comp)
                            'VolumeName' = $BDEOutput[8]
                            'VolumeLetter' = $BDEOutput[7].Split(" ")[1].Trim()
                            'BitLockerVersion' =  $BDEOutput[11].Split(":")[1].Trim()
                            'BitLockerStatus' = $BDEOutput[12].Split(":")[1].Trim()
                            'PercentEncrypted' = $BDEOutput[13].Split(":")[1].Trim()
                            'EncryptionMethod' = $BDEOutput[14].Split(":")[1].Trim()
                            'ProtectionStatus' = $BDEOutput[15].Split(":")[1].Trim()
                            'LockStatus' = $BDEOutput[16].Split(":")[1].Trim()
                            'KeyProtechtors' = (($BDEOutput[19..$BDEOutput.Length] -join ",").Replace(" ",""))

                            }#Properties

                        $Object = New-Object -TypeName psobject -Property $Properties
                        $Object = $Object | Select ComputerName,VolumeName,VolumeLetter,BitLockerStatus,BitLockerVersion,PercentEncrypted,EncryptionMethod,ProtectionStatus,LockStatus,KeyProtechtors
                        Write-Output $Object
                    }#If
                else
                {
                        # Computer has a multiple drives
                        $Properties = @{
                            'ComputerName'   = $($Comp)
                            'VolumeName' = $BDEOutput[8]
                            'VolumeLetter' = $BDEOutput[7].Split(" ")[1].Trim()
                            'BitLockerVersion' =  $BDEOutput[11].Split(":")[1].Trim()
                            'BitLockerStatus' = $BDEOutput[12].Split(":")[1].Trim()
                            'PercentEncrypted' = $BDEOutput[13].Split(":")[1].Trim()
                            'EncryptionMethod' = $BDEOutput[14].Split(":")[1].Trim()
                            'ProtectionStatus' = $BDEOutput[15].Split(":")[1].Trim()
                            'LockStatus' = $BDEOutput[16].Split(":")[1].Trim()
                            'KeyProtechtors' = (($BDEOutput[20..24] -join ",").Replace(" ",""))
                        }#Properties

                        $Object = New-Object -TypeName psobject -Property $Properties
                        $Object = $Object | Select ComputerName,VolumeName,VolumeLetter,BitLockerStatus,BitLockerVersion,PercentEncrypted,EncryptionMethod,ProtectionStatus,LockStatus,KeyProtechtors
                        Write-Output $Object

                        $Properties = @{
                            'ComputerName'   = $($Comp)
                            'VolumeName' = $BDEOutput[26]
                            'VolumeLetter' = $BDEOutput[25].Split(" ")[1].Trim()
                            'BitLockerVersion' =  $BDEOutput[29].Split(":")[1].Trim()
                            'BitLockerStatus' = $BDEOutput[30].Split(":")[1].Trim()
                            'PercentEncrypted' = $BDEOutput[31].Split(":")[1].Trim()
                            'EncryptionMethod' = $BDEOutput[32].Split(":")[1].Trim()
                            'ProtectionStatus' = $BDEOutput[33].Split(":")[1].Trim()
                            'LockStatus' = $BDEOutput[34].Split(":")[1].Trim()
                            'KeyProtechtors' = (($BDEOutput[37..$BDEOutput.Length] -join ",").Replace(" ",""))
                            }#Properties

                        $Object = New-Object -TypeName psobject -Property $Properties
                        $Object = $Object | Select ComputerName,VolumeName,VolumeLetter,BitLockerStatus,BitLockerVersion,PercentEncrypted,EncryptionMethod,ProtectionStatus,LockStatus,KeyProtechtors

                        Write-Output $Object
                    }#else

            }#foreach

        }#Process

    End {

        Write-Verbose "All Done"

        }#end

}#Function Get-BitLockerStatus