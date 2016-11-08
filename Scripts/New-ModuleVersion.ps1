$ModuleName = 'LazyAD'
$BaseBuildDir = 'D:\Git\Public-PowerShell'
$FinalBuildDir = (Join-Path $BaseBuildDir $ModuleName)
$ModuleDir = "$env:ProgramFiles\WindowsPowerShell\Modules"
$LatestBuild = (((Get-Module -ListAvailable | Where{$_.Name -eq $ModuleName} | Select -first 1) | Select -expand Version))
[version]$NewBuild = '1.0.3'

if(($LatestBuild -eq $NewBuild))
{
    Throw "Versions are Equal"
}


# Copy the Modules to $BaseBuildDir (for Git)
Copy-Item "$ModuleDir\$moduleName\$LatestBuild" "$FinalBuildDir\$NewBuild" -Recurse -Force

Set-Location "$FinalBuildDir\$NewBuild"
#Get-ChildItem -Path $BaseBuildDir -Directory | Where{$_.LastWriteTime} 

$OriginalConfig = Get-Content $($ModuleName+".psd1")
$moduleInfo = (Import-LocalizedData -file $($ModuleName+".psd1")).ModuleVersion
$CurrentVersion = $LatestBuild.ToString()
$NewVersion = $NewBuild.ToString()

$OriginalConfig | ForEach-Object { $_ -replace $CurrentVersion,$NewVersion} | Set-Content TempData.psd1 -Force

Rename-Item $($ModuleName+".psd1") $($ModuleName+".psd1.old")
Rename-Item TempData.psd1 $($ModuleName+".psd1")

#Set-Location "D:\Git\Public-PowerShell\LazyAD\1.0.3"
#Import-LocalizedData -FileName Temp1.psd1