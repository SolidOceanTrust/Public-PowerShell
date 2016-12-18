#$PDQComputers = import-csv -Path D:\AllGoodPCs_NoVMs.csv | Select -expand Name
$PDQComputers = import-csv -Path D:\AllGoodPCs_NoVMs.csv | Select -expand Name
$PDQComputers = $PDQComputers[0..25]

workflow BitLockerConfigCheck {
    param([string[]]$Computers)

    foreach -parallel ($comp in $Computers) {
  
#Out-File -InputObject "C:\Windows\System32\bdehdcfg.exe -driveinfo >> c:\bl.txt" -Path "\\$comp\c`$\bl.bat" -Force -Encoding ascii

        # Create
       #schtasks /Create /S $comp /TN BitLockerCheck /TR "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file c:\BL.ps1" /SC Daily /RU SYSTEM /F
       schtasks /Create /S $comp /TN BitLockerCheck /TR "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file \\usw7bnabel\share\BL.ps1" /SC Daily /RU SYSTEM /F

        # Run
        schtasks /Run /TN BitLockerCheck /S $comp
        Start-Sleep -Seconds 5

        # Wait for Schedule Task to Complete
        $Condition = $true
        While($Condition -eq $true)
        {
            Start-Sleep -Seconds 25
            #Write-OutPut "Task Still Running"

            if( (schtasks /query /fo CSV /S $Comp | ConvertFrom-Csv | Where{$_.TaskName -eq "\BitLockerCheck"}).Status -ne "Running")
            {
                $Condition = $false
               # Write-OutPut "Task Stopped!"
            }#False

        }
        # Validate File
        if((Test-Path "\\$comp\c`$\bl.txt") -eq $true)
        {
            #Write-OutPut "Found the Text File!"
            $BLResult = Get-Content "\\$comp\c`$\bl.txt"
            #$properties = @{'ComputerName' = $comp ; 'BitLockerResult' = $BLResult}
            Out-File -InputObject "$comp,$BLResult" -Append -FilePath "\\usw7bnabel\share\WorkFlowData.txt"
            #$object = New-Object -TypeName psobject -Property $properties
            
            #Write-Output $properties
        }
        # Delete Task
        schtasks /Delete /TN BitLockerCheck /F /S $comp

     }#Foreach

}#Workflow

BitLockerConfigCheck -Computers $PDQComputers