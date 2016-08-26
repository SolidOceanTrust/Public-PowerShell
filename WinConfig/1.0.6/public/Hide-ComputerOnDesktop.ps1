function Hide-ComputerOnDesktop {
    $Key1 = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\'
    $Key2 = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu'

    Set-ItemProperty -Path $key1 -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force
    Set-ItemProperty -Path $key2 -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force

    #Restart Windows Explorer
	#try{Stop-Process -processname explorer -Force -ErrorAction Stop | Out-Null} catch {}
    Restart-Explorer
    Write-Output "My Computer is now removed on the desktop"

}#Hide-ComputerOnDesktop