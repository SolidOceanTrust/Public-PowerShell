Function Disable-ServerMgrAtLogon{
    $key1 = "HKLM:\SOFTWARE\Microsoft\ServerManager\"
    $key2 = "HKLM:\Software\Microsoft\ServerManager\Oobe\"

    if(Test-Path $key1)
    {
        Set-ItemProperty -Path $key1 -Name "DoNotOpenServerManagerAtLogon" -Value 1 -Force
    }

     if(Test-Path $key2)
    {
        Set-ItemProperty -Path $key2 -Name "DoNotOpenInitialConfigurationTasksAtLogon" -Value 1 -Force
    }

    Write-Output "Launch Server Manager at Logon is Disabled"

}#Disable-ServerMgrAtLogon