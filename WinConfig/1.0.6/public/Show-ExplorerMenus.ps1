Function Show-ExplorerMenus {
	$basekey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
	 Set-ItemProperty $basekey AlwaysShowMenus 1

	#Restart Windows Explorer
	#try{Stop-Process -processname explorer -Force -ErrorAction Stop | Out-Null} catch {}
    Restart-Explorer
}#Show-ExplorerMenus