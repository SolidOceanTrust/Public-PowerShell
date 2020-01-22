function Get-PuppetValidate {
    [CmdletBinding()]
    [Alias("puppetvalidate","pcheck")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            # Validate the Path to FileName
            if ( -Not ($_ | Test-Path) ) {
                throw "$filename not found :("
            }
            return $true
            # Validate that $fileName is actually a File
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The fileName argument must be a file. Folder paths are not allowed."
            }
            return $true
            # Validate the Extension Ends in .config
            if ($_ -notmatch "(\.pp)" ) {
                throw "$fileName does not end in '.pp' "
            }
        })]
        [System.IO.FileInfo] $file
    )
    
    # Check if Puppet is in the path, if not, Fail

    # Run Puppet ParserValidate
    puppet parser validate $file

    # Run Puppet lint (Gem)
    puppet-lint $file
}