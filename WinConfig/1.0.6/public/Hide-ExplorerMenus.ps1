Function Hide-ExplorerMenus {
	$basekey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
	 Set-ItemProperty $basekey AlwaysShowMenus 0

	#Restart Windows Explorer
	#try{Stop-Process -processname explorer -Force -ErrorAction Stop | Out-Null} catch {}
    Restart-Explorer
}#Hide-ExplorerMenus