function Disable-IEStartupWizard {
    $key = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
    if(Test-Path $key)
    {
        Set-ItemProperty -Path $key -Name "DisableFirstRunCustomize" -Value 1 -Force
    }

    Write-Output "IE Start Startup is Disabled"
}#Disable-IEStartupWizard