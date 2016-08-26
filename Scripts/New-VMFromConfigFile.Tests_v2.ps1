##### OverView #####
<#
    Drop config file into watched dir
    AB will pickup file, validate it's config
        Config Bad, FAIL AB Job > Send email about why it failed
        Config Good,
            Connect to vSphere
            Copy VM from Template
            Apply Config from Script
            Boot VM
                Wait for responding to "\\$VMName\c$\DSC"
                when wait is over, copy DSC file or config script
                run script
                Send Email when complete
#>

#requires -module ActiveDirectory

#requires -module Pester

Add-PSSnapin -Name VMWare.*

### Gloabl Data
$Global:FreeSpaceThreashHoldGB = 100
$Global:MaxRamThreashHold = 12    # Setting this at a value where some jerk can't try to provision a server with 200GB of RAM. Manners matter!
$Global:MaxCPUThreashHold = 4
$Global:invalidchars = @("_","'","`"","'`'"," ","~","!","@","#","$","%","^","&","*","(",")","+","{","}","[","]","|","\","/",":",";","<",">","?")
$Global:Report = @()
$Global:Final = @()


# Build VM Object from Config File
$Data = [xml] (Get-Content .\VMConfig_Template.xml)

# Echo Back $VMObject
Write-Output $Data.VMObject

#Build vCenterFQDN Object
$vCenterFQDN = "$("$($Data.VMObject.vCenterServer).$($Data.VMObject.DomainName)")"

# Connect to vCenter to Validate some config items
#try { Connect-VIServer -server $vCenterFQDN -erroraction Stop  } catch {throw "could not connect to vCenter"}

#Run Pester Tests to Validate Config Files
Describe "Validate Config File Contents"{

    It "[Config File] Should not have any null values" {
        $Data.VMObject.GetEnumerator() | ForEach-Object {$_."#text" -ne $null} | Should Be "True"
    }

    It "[VM] Should have a valid computername (< 15 chars)" {
        $Data.VMObject.VMName.Length | Should Belessthan 15
    }

     It "[VM] Should have a valid computername (No invalid chars)" {
            foreach ($char in $data.VMObject.VMName.ToCharArray())
            {
                if($invalidchars -like $char)
                { "BadChar" | Should BeNullOrEmpty }
            }#foreach ($char in $data.VMObject.VMName.ToCharArray())
    }

    It "[VM] Should Not already exist anywhere (AD/VCenter)"{
        $TestAD = Get-AdComputer -Properties SamAccountName -Filter 'Name -like "$Data.VMObject.VMName"'
        $TestVMWare = Get-VM -Name $Data.VMObject.VMName -ErrorAction SilentlyContinue

        $TestAD | Should BeNullOrEmpty
        $TestVMWare | Should BeNullOrEmpty
    }

    It "[VM HW Config] Should have a valid HW configuration" {
        [int]$Data.VMObject.CPU | Should BeGreaterThan 0
        [int]$Data.VMObject.CPU | Should BeLessThan $Global:MaxCPUThreashHold
        [int]$Data.VMObject.RAM | Should BeGreaterThan 0
        [int]$Data.VMObject.RAM | Should BeLessThan $Global:MaxRamThreashHold
    }

    It "[VM HW Config] Should have valid Network configuration" {
        [System.Net.IPAddress]$Data.VMObject.IPAddress | Should BeOfType System.Net.IPAddress
        [System.Net.IPAddress]$Data.VMObject.SubNetMask | Should BeOfType System.Net.IPAddress
        [System.Net.IPAddress]$Data.VMObject.DefaultGateway | Should BeOfType System.Net.IPAddress
        [System.Net.IPAddress]$Data.VMObject.DNS1 | Should BeOfType System.Net.IPAddress
        [System.Net.IPAddress]$Data.VMObject.DNS2 | Should BeOfType System.Net.IPAddress

        $TestPing = Test-Connection -count 1 -quiet -erroraction SilentlyContinue -computername $Data.VMObject.IPAddress
        $TestPing | Should Be False
    }

    It "[AD] Should be placed into a valid OU" {
        $TestSubNet = Get-ADOrganizationalUnit -Identity $Data.VMObject.OU
        $TestSubNet | Should Not BeNullOrEmpty
    }

    It "[VMWare Env] Should be placed into a valid Cluster" {
        $TestCluster = ((Get-Cluster | Where{$_.Name -eq $Data.VMObject.VMCluster})) -ne $Null
        $TestCluster | Should Be True
    }

    It "[VMWare Env] Should be placed into a valid Datastore" {
        $TestDataStore = ((Get-Datastore | Where{$_.Name -eq $Data.VMObject.DataStore})) -ne $Null
        $TestDataStore | Should Be True
    }

    It "[VMWare Env] Should be placed into a Datastore with Enough Free Space" {
        $TestDataStoreFreeSpace =
            ((Get-Datastore | Where{$_.Name -eq $Data.VMObject.DataStore})).FreeSpaceGB -as [int] -ge $Global:FreeSpaceThreashHoldGB
        $TestDataStoreFreeSpace | Should Be True
    }
}#Describe "Validate Config File Contents"{

# VMWare
# Datastore exisits
# Datastore free space
# Cluster Exists
# Cluster in healthy state
# Host oversubscription?


<#
##### Validation #####
#ensure required modules are present


## Validate Phase

#File
[D] - Are all fields completed?
[D] - Are the number of fields equal to what we expect?
[D] - Can I connect to vCenter?


Is the Template VM real?
Is the VMcustomization valid?

[D] - VMName already exist in Vcenter?
Is the VMName valid? {No Spaces, no special chars, length < 15 chars}
[D] - Is Computername already exist in AD?

[D] - IS IP address respond to pings?
[D] - Is CPU = 1 or 2?
[D] - Is RAM = integer > 2 but < 12 ?

Is VMCluster match $(Get-Cluster)
Is Datastore match $(Get-DataStore) & Does $Datastore have > 70GB free

[D] - Is $OU match $(Get-ADOrganizationalUnit) & Does this $ou contain computer objects?


$VMName should be <15 chars, no " ", no special chars
[D] - $CPU should be 1 or 2
[D] - $RAMGB should be 4,8,12
$VMCluster should be $(Get-Cluster)
$Datastore should be $(Get-Datastore) [Fail if less than 50GB of free space, Fail if does not exist]
$OU should be $(Get-ADOrganizationalUnit) [Fail if $OU does not contain computer objects, fail if $OU is "Computers"]



#>
