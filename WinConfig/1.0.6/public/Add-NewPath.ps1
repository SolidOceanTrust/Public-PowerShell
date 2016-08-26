function Add-NewPath {
    [CommandletBinding()]
    [Alias('addpath')]
    param (
        [String] $newPathDir        
    )
    $currentPath = $env:Path
    $currentPath | Out-File C:\ProgramData\Path_Backup.txt -Force
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$newPathDir", "Machine")

    # Thanks chocolatey
    refreshenv
    Write-Output -InputObject ($env:Path -split ';')
}