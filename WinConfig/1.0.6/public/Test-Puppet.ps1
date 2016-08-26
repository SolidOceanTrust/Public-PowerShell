function Test-Puppet {
    [CmdletBinding()]
    [Alias('tstppt')]
    param (
        # File Name
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            if($_ -notmatch "(\.pp)"){
                throw "The file specified in the path argument must be of type pp"
            }
            return $true 
        })]
        [System.IO.FileInfo]$FilePath
    )
    
    begin {}
    
    process {
        try {
           Write-Host -ForegroundColor Green "Running Puppet Parser Validate on $($FilePath)"
           puppet parser validate $FilePath
           
           Write-Host -ForegroundColor Green "Running Puppet-Lint on $($FilePath)"
           puppet-lint $FilePath 
        }
        catch {
            Throw 'unable to run validate or linter functions. Is puppet installed?'
        }
        finally {
            
        }
    }
    
    end {
    }
}