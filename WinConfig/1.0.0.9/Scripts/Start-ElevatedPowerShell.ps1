Function Start-ElevatedPowerShell
{
	[CmdletBinding()]
    [Alias('software','soft')]
    param ()
	#Shamlessly Stolen from "Hey Scripting Guy"
    #http://blogs.technet.com/b/heyscriptingguy/archive/2015/07/30/launch-elevated-powershell-shell.aspx

    Start-Process PowerShell -Verb Runas

 }  #Function Start-ElevatedPowerShell