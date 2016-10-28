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

Export-ModuleMember -function * -alias *