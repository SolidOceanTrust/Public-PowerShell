 Function Set-PathOptions
 {
	[Cmdletbinding()]
	 Param(
			## Backup Params
			[parameter(Mandatory=$True,
			ValueFromPipeline=$True,
			Position=0,
			ParameterSetName='Update')]
			[switch]$Update,

			[parameter(Mandatory=$True,
			Position=1,
			ParameterSetName='Update')]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
			$NewFolderPath,

			## Remove Params
			[parameter(Mandatory=$False,
			ValueFromPipeline=$True,
			Position=0,
			ParameterSetName='Remove')]
			[switch]$Remove,

			[parameter(Mandatory=$False,
			Position=1,
			ParameterSetName='Remove')]
			$RemoveFolderPath,

			## Backup Params
			[parameter(Mandatory=$False,
			ValueFromPipeline=$True,
			Position=0,
			ParameterSetName='Backup')]
			[switch]$Backup,

			[parameter(Mandatory=$False,
			Position=1,
			ParameterSetName='Backup')]
			[ValidateScript({(Test-Path $_) -eq $True})]
			[String[]]$BackupPath = $env:USERPROFILE+"\Desktop"

	      )#Param

		# Determine what to do based on Parameter Set Name
		switch ($PsCmdlet.ParameterSetName)
	   {
		 "Update"  {
				     # "Borrowed" From http://blogs.technet.com/b/heyscriptingguy/archive/2011/07/23/use-powershell-to-modify-your-environmental-path.aspx
					 # Get the current search path from the environment keys in the registry.

                     $OldPath = [System.Environment]::GetEnvironmentVariable("path")

					# See if a new folder has been supplied.

					IF (!$NewFolderPath)
					{
                        Write-Output "No Folder Supplied. $ENV:PATH Unchanged"
                        Return ‘No Folder Supplied. $ENV:PATH Unchanged’
                    }

					# See if the new Folder is already in the path.
					IF ($OldPath | Select-String -SimpleMatch $NewFolderPath)
					{
                        Write-Output "Folder already within $ENV:PATH"
                        Return "Folder already within $ENV:PATH"
                    } #If

					# Set the New Path

					$NewPath = $OldPath+ ’;’ + $NewFolderPath

					[System.Environment]::SetEnvironmentVariable("path",$NewPath,'Machine')

					# Show our results back to the world

					Return $NewPath -split ";"

				} #Update

		"Remove"  {
					# Get the Current Search Path from the environment keys in the registry

					$NewPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path

					# Find the value to remove, replace it with $NULL. If it’s not found, nothing will change.

					$NewPath=$NewPath –replace $RemoveFolderPath,$NULL

					# Update the Environment Path

					Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

					# Show what we just did

					Return $NewPath -split ";"

			       }  #Remove

		 "Backup"  {

					# Get the Current Search Path from the environment keys in the registry
                    $output = @()

                    $Header = "------------------------------------------Path Backup:  $((Get-Date).ToString('MM-dd-yyyy'))------------------------------------------------"
                    $TxtPath = $env:Path -split ";"
                    $footer = "------------------------------------------EOF-----------------------------------------------------------------------------------------------"

                    #Build File From Array
                    $output += $Header
					$output += $TxtPath
                    $output += $Footer
                    $output | Out-File "$BackupPath\PathBackup.log" -Confirm:$false -Append

					Write-Output "Path backed up to $($BackupPath)"
                    Invoke-Item -Path "$BackupPath\PathBackup.log"
                    Remove-Variable -Name Output -Confirm:$False -ErrorAction SilentlyContinue

					}  #Backup
      }#Switch

 } #Function Set-PathOptions