Function Show-FileExtensions {
	$basekey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
	 Set-ItemProperty $basekey HideFileExt 0

	#Restart Windows Explorer
	#try{Stop-Process -processname explorer -Force -ErrorAction Stop | Out-Null} catch {}
    Restart-Explorer
}#Show-FileExtensions