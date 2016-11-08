Function Get-ADGroupLike
{
    [CmdletBinding()]
    [Alias("adglike")]
    param(
            [string]$Like
        )#param

    $InputFinal = "*$Like*"
    Get-ADGroup -Filter 'Name -like $InputFinal'
}

Function Get-ADGroupMemberLike
{
    [CmdletBinding()]
    [Alias("adgmlike")]
    param(
            [string]$group,
            [switch]$Recursive = $false,
            [switch]$Filter = $false
        )#param
    
    $basecmd = $("Get-ADGroupMember -Identity `"$group`"")
    
    Switch ($Recursive)
    {
        $true { $basecmd += " -Recursive" }
        $false {}
    }#Switch ($Recursive)
    

    Switch ($Filter)
    {
        $true {$basecmd += " | Select Name,SamAccountName,distinguishedName"}
        $false {}
    }#Switch ($Recursive)

    #Final Output
    $finalcmd = $basecmd.ToString()

    Invoke-Expression $finalcmd
}

Function Get-ADUserLike
{
    [CmdletBinding()]
    [Alias("adulike")]
    param(
            [string]$Like,
            [switch]$Filter = $false
        )#param

    $InputFinal = "*$Like*"
    $basecmd = $("Get-ADUser -Filter 'Name -like `"$InputFinal`"' -Properties *")

     Switch ($Filter)
    {
        $true {$basecmd += " | Select Name,SamAccountName,UserPrincipalName,LockedOut,Enabled"}
        $false {}
    }#Switch ($Recursive)

    $finalcmd = $basecmd.ToString()

    Invoke-Expression $finalcmd

    #Get-ADUser -Filter 'Name -like $InputFinal' -Properties * | Select Name,SamAccountName,UserPrincipalName,LockedOut,Enabled
}

Function Get-ADComputerLike
{
    [CmdletBinding()]
    [Alias("adclike")]
    param(
            [string]$Like
        )#param

    $InputFinal = "*$Like*"
    Get-ADComputer -Filter 'Name -like $InputFinal' -Properties * | Select Name,DNSHostName,Enabled,SamAccountName,SID,ObjectClass
}

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
function Test-IsLocked
{
    [CmdletBinding()]
    [Alias("locked","lock")]
    [OutputType([bool])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $UserName
    )#Param

    Begin
    {
        try {Import-Module ActiveDirectory -ErrorAction Stop}
        catch {Write-Error $_}
    }#Begin
    Process
    {
        try {
                (Get-ADUser $UserName -Properties LockedOut -ErrorAction Stop).LockedOut
            } #try

        catch {
                Write-Error $_ ; "Is the user real?"
              }#Catch
    
    }#Process
    End
    {
    }#End
}#Function
Export-ModuleMember -function * -alias *