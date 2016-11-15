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
Function New-Commit
{
    [CmdletBinding()]
    [Alias("nc","gitc")]
    [OutputType([string])]

    param (
            [Alias("msg","cm")] 
            [string]$CommitMsg
        )
    
    try {
            git add --all
            git commit -m $CommitMsg
            git push

        }
    catch {
            Write-Error -Exception $_
        }

}