Function Get-PDQPackages
{
    #Requires -Modules PSSQLite
    Param($PDQServer)
}#Get-PDQPackages

Function Get-PDQDeploymentStatus
{
    #Requires -Modules PSSQLite
    Param($PDQServer,$DeploymentID)
}#Get-PDQDeploymentStatus

Function Invoke-PDQDeploy
{
    #Requires -Modules PSSQLite
    Param($PDQServer,$PDQPackages,$Targets)
}#Invoke-PDQDeploy
$DBPath = "C:\ProgramData\Admin Arsenal\PDQ Deploy"

copy 'C:\Program Files\WindowsPowerShell\Modules\PSSQLite*' "\\PDQServer\c$\Program Files\WindowsPowerShell\Modules\PSSQLite\" -Recurse
Import-Module PSSQLite
#  Import-Module "C:\Program Files\WindowsPowerShell\Modules\PSSQLite\PSSQLite.psm1"
$database = $(Join-Path $DBPath database.db)
$query = "select name from packages order by name"
#Invoke-SqliteQuery -Query $query -Database $database
$pdqPackages = Invoke-SqliteQuery -Query $query -Database $database
$FinalPDQPackageList = $pdqPackages.Name

<#
$SQLLitePath = "C:\Program Files (x86)\Admin Arsenal\PDQ Deploy"
$DBPath = "C:\ProgramData\Admin Arsenal\PDQ Deploy"
$ReportFile = "$env:TEMP\PDQ"

@"
select name from packages order by name;
"@ | Out-File c:\commands.txt

@"
"C:\Program Files (x86)\Admin Arsenal\PDQ Deploy\sqlite3.exe" "C:\ProgramData\Admin Arsenal\PDQ Deploy\database.db" < "select name from packages order by name;" > "c:\PDQPackages.csv"
"@ | Out-File c:\PDQPackages.bat -Force

Get-Content c:\PDQPackages.bat
cmd /c C:\PDQPackages.bat


$(Join-Path $SQLLitePath sqllite3.exe) < $(Join-Path $DBPath database.sb) > $(Join-Path $SQLLitePath PDQPackages.csv)

  cd "C:\ProgramData\Admin Arsenal\PDQ Deploy\"
    sqlite3 database.db < commands.txt
    sqlite3 "C:\ProgramData\Admin Arsenal\PDQ Deploy\Database.db" < "C:\Program Files (x86)\Admin Arsenal\PDQ Deploy\command.txt" > "C:\Program Files (x86)\Admin Arsenal\PDQ Deploy\Packages.csv"

#>