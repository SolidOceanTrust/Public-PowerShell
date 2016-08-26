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
            [switch]$Recursive = $false
        )#param
    
    if($Recursive -eq $true)
    {
        Get-ADGroupMember -Identity $group -Recursive| Select @{label="$Group  Members";e={$_.Name}}
    }#True
    Else { Get-ADGroupMember -Identity $group | Select @{label="$Group  Members";e={$_.Name}} }
}

Function Get-ADUserLike
{
    [CmdletBinding()]
    [Alias("adulike")]
    param(
            [string]$Like
        )#param

    $InputFinal = "*$Like*"
    Get-ADUser -Filter 'Name -like $InputFinal' -Properties * | Select Name,SamAccountName,UserPrincipalName,LockedOut,Enabled
}

Export-ModuleMember -function * -alias *