<#
.Synopsis
   
.DESCRIPTION
   
.EXAMPLE
   
.EXAMPLE
   
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