$ModuleName = 'LazyAD'
$BaseBuildDir = 'D:\Git\Public-PowerShell'
$FinalBuildDir = (Join-Path $BaseBuildDir $ModuleName)
$ModuleDir = "$env:ProgramFiles\WindowsPowerShell\Modules"
$LatestBuild = (((Get-Module -ListAvailable | Where{$_.Name -eq $ModuleName} | Select -first 1) | Select -expand Version))
[version]$NewBuild = '1.0.4'

if(($LatestBuild -eq $NewBuild))
{
    Throw "Versions are Equal"
}

# Copy the Modules to $BaseBuildDir (for Git)
Copy-Item "$ModuleDir\$moduleName\$LatestBuild" "$FinalBuildDir\$NewBuild" -Recurse -Force

Set-Location "$FinalBuildDir\$NewBuild"

$OriginalConfig = Get-Content $($ModuleName+".psd1")

$moduleRAW = (Import-LocalizedData -BaseDirectory . -FileName $($ModuleName+".psd1"))
$moduleVersion = $moduleRAW.ModuleVersion

if($moduleVersion -eq $LatestBuild)
{ Throw "Module from $modulesDIR doesn't eq Module version from file" }

#$moduleInfo  = (Import-LocalizedData -BaseDirectory . -FileName $($ModuleName+".psd1")).ModuleVersion

$CurrentVersion = $LatestBuild.ToString()
$NewVersion = $NewBuild.ToString()

$OriginalConfig | ForEach-Object { $_ -replace $CurrentVersion,$NewVersion} | Set-Content TempData.psd1 -Force

Rename-Item $($ModuleName+".psd1") $($ModuleName+".psd1.old")
Rename-Item TempData.psd1 $($ModuleName+".psd1")
Remove-Item $($ModuleName+".psd1.old") -Confirm:$false