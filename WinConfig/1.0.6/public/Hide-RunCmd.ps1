Function Hide-RunCmd {

    # OS Detection required. Will not work on Servers/Clients 2012+ / Win8 +
    # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724832(v=vs.85).aspx
    if( (gwmi Win32_operatingsystem).Version -le 6.1)
        {
            Write-Output "Compatible OS Detected. Making the change now"
            $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Set-ItemProperty -Path $key -Name "Start_ShowRun" -Value 0 -Force
        }
    else { Write-Output "NO Compatible OS Detected. Nothing will happen. Sorry!"}

}#Hide-RunCmd