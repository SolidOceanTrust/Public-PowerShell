Function New-SystemShortCuts
 {
	# Borrowed: https://social.technet.microsoft.com/forums/scriptcenter/en-US/e656ed4f-52de-474b-888a-a226a23bf5eb/assigning-icon-to-a-shortcut-in-powershell
	# Borrowed: http://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell
	# Borrowed: http://blogs.technet.com/b/heyscriptingguy/archive/2005/08/12/how-can-i-change-the-icon-for-an-existing-shortcut.aspx

	#Borrowed:
    # http://www.howtogeek.com/howto/windows/create-a-shortcut-for-locking-your-computer-screen-in-windows-vista/

	 [cmdletbinding()]
	 param(

			[parameter(Mandatory=$True,
			Position=0)]
			[ValidateSet("Logoff","Shutdown","Reboot","Lock")]
			[string[]]$Shortcuts,
		 	[string]$DestinationPath = "$Home\Desktop"
		 )# Param

    foreach($ShortCut in $Shortcuts){

            # Evaluate Arguments to pass
	        Switch($Shortcut) {
	 		 "Logoff"{ $ShortCutArgs = $null ; $exe = "C:\Windows\System32\logoff.exe" ; $iconID = 43}
			 "Shutdown" {$ShortCutArgs = "/S /F /t 00" ; $exe = "C:\Windows\System32\shutdown.exe" ; $iconID = 27}
			 "Reboot"{$ShortCutArgs = "/R /F /t 00" ; $exe = "C:\Windows\System32\shutdown.exe" ; $iconID = 77}
		      "Lock" {$ShortCutArgs = "user32.dll, LockWorkStation" ; $exe = "c:\Windows\System32\rundll32.exe" ; $iconID = 47}

			  }# Switch

            $WshShell = New-Object -comObject WScript.Shell
			$Shortcut = $WshShell.CreateShortcut($DestinationPath+'\'+$Shortcut+'.lnk')
			$Shortcut.TargetPath = $exe
			$Shortcut.Arguments = $ShortCutArgs
			$Shortcut.IconLocation = "C:\Windows\System32\SHELL32.dll,$iconID"
			$Shortcut.Save()
	}#foreach


 } #Function New-SystemShortCuts