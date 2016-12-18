function Hide-HiddenFiles {
	$basekey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
	 Set-ItemProperty $basekey Hidden 0

	#Restart Windows Explorer
	#try{Stop-Process -processname explorer -Force -ErrorAction Stop | Out-Null} catch {}
    Restart-Explorer
}#Hide-HiddenFiles