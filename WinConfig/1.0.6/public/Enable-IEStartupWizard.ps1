function Enable-IEStartupWizard {
    $key = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
    if(Test-Path $key)
    {
        Set-ItemProperty -Path $key -Name "DisableFirstRunCustomize" -Value 0 -Force
    }

    Write-Output "IE Start Startup is Enabled"
}#Enable-IEStartupWizard