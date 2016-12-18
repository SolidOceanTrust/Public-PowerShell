#Updated starting on 12/17/16

# Let's make sure that the "Scripts" Directory exists where it should be! Recognize my folder structure!!!!
# Yes, I know you can use $PSScriptRoot, but I want to maintain comp. with PS v2....
$ModuleRoot = Split-Path $MyInvocation.MyCommand.Path

# Dot Source All scripts inside of the "Scripts" directory.
$ScriptsDir = (Join-Path $ModuleRoot Scripts)
If( (Test-Path $ScriptsDir) -eq $false)
{
    Throw "Cannot find 'Scripts' directory in exepected location. `n
           Something is very wrong with this module. Cannot continue. `n
           Goodbye sweet world"
           Exit
}
Else
{
    Get-ChildItem -Path $ScriptsDir -Filter *.ps1 | ForEach-Object {

        Write-Output "Importing function : $_"
        ."$ScriptsDir\$_"

    }#foreach

}#Else



Function Show-StdConfig
{
    Write-Output "Standard Config Options are:"
    Write-Output "Enable-RemoteDesktop"
    Write-Output "Disable-UAC"
    Write-Output "Show-HiddenFiles"
    Write-Output "Show-FileExtensions"
    Write-Output "Disable-InternetExplorerESC"
    Write-Output "Show-ComputerOnDesktop"
    Write-Output "Disable-IEStartupWizard"
    Write-Output "Disable-ServerMgrAtLogon"
    Write-Output "Disable-IPv6"
    Write-Output "Disable-WindowsFirewall"
    Write-Output "Set-PowerPlan -PowerPlan High_Performance"
    Write-Output "Disable-WindowsFirewall"
    Write-Output "Disable-Hibernation"
    Write-Output "Set-TimeZone Eastern Standard Time "
    Write-Output "Disable-MassStorage"

 } #Function Show-StdConfig

 Function Set-StdConfig
{
    Write-Warning "STOP! Running this command will make batch changes!"
    Write-Warning "You have 10 seconds to cancel the execution of this function"
    Write-Warning "Hint: control-c to 'break' "
    Start-Sleep -Seconds 10

    Write-Output "Enabling Remote Desktop" ; Enable-RemoteDesktop
    Write-Output "Disabling UAC" ; Disable-UAC
    Write-Output "Showing Hidden Files" ; Show-HiddenFiles
    Write-Output "Showing File Extenstions" ; Show-FileExtensions
    Write-Output "Disabling Internet Explorer Enhanced Security" ; Disable-InternetExplorerESC
    Write-Output "Showing the 'Computer' on the desktop" ; Show-ComputerOnDesktop
    Write-Output "Disabling Internet Explorer Startup Wizard" ; Disable-IEStartupWizard
    Write-Output "Disabling Server Manager Startup at Logon" ; Disable-ServerMgrAtLogon
    Write-Output "Disabling Windows Firwall" ; Disable-WindowsFirewall
    Write-Output "Disabling IPv6" ; Disable-IPv6
    Write-Output "Setting TimeZone to EST" ; Set-TimeZone "Eastern Standard Time"
    Write-Output "Setting PowerPlan to 'High Performance' " ; Set-PowerPlan -PowerPlan High_Performance
    Write-Output "Disabling Hibernation' " ; Disable-Hibernation
    Write-Output "Disabling Mass Storage' " ; Disable-MassStorage

    # Check for Explorer not started, then start it
    if(-not (Get-Process explorer)){ Start-Process "explorer" -ErrorAction SilentlyContinue}
 } #Function Set-StdConfig

Export-ModuleMember -function * -alias *