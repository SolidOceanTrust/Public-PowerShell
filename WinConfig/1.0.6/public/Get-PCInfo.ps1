Function Get-PCInfo
{
    [CmdletBinding()]
    [Alias('pcinfo','pci')]
    [OutputType([String])]

    Param(
            [Alias('cn','pc')]
            [string[]]$ComputerName = $env:COMPUTERNAME,

            [Alias('cred','account')]
            [pscredential]$Credential
          )#param


      begin
      {
        Write-Verbose "[Begin] Checking All computers for Status"
        Write-Verbose "[Begin] Supplied Computers: $computerList "

        if($Credential)
        {
            $CredentialObject = $Credential
        }
        else {$CredentialObject = $null}
        $ComputerName | ForEach-Object {
            if((Test-Connection -Quiet -Count 1 -ComputerName $_ ) -eq $true)
              {
                   [array]$OnlinePCs += $_
              }#Ping = True
            else {
                     [array]$FaliedPCs += $_
                  }
        }#Foreach-object

        Write-Verbose "[Begin] Checking $($OnlinePCs.Count) Computer(s) for information"
        Write-Verbose "[Begin] Online PCs: $OnlinePCs "

      } #Begin

      Process
      {
          Foreach($computer in $OnlinePCs)
          {
              Try{
                        $HWInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer -Credential $CredentialObject
                        $CurrentUser = try{(Get-WmiObject -Class Win32_Process -computer $Computer -Credential $CredentialObject -ErrorAction Stop| Where{$_.name -like '*explorer*'}).GetOwner().User | Select -Unique} catch {"none"}
                        $PageFileInfo = Get-WmiObject -Class Win32_PageFileUsage -ComputerName $Computer -Credential $CredentialObject
                        $Uptime = (New-Timespan -Start (($upt = Get-WmiObject -Query 'Select LastBootupTime FROM Win32_Operatingsystem' -ComputerName $Computer -Credential $CredentialObject )).ConvertToDateTime($upt.LastBootUpTime) ).Days

                        $Object = @{
                                      'ComputerName'  = $Computer.ToUpper()
                                      'Make'          = $HWInfo.Manufacturer.trim()
                                      'Model'         = $HWInfo.Model.Trim()
                                      'RAM(GB)'       = ($HWInfo.TotalPhysicalMemory /1GB) -as [int]
                                      'PageFileDrive'  = $($PageFileInfo.Name -split ":")[0]
                                      'PageFileSizeGB'  = $($PageFileInfo.AllocatedBaseSize / 1024 -as [int])
                                      'CurrentUser'   = $CurrentUser
                                      'Uptime(Days)'  = $Uptime
                          }#Object

                          $PSObject = New-Object -TypeName PSObject -Property $Object

                          $PSObject = $PSObject | Select ComputerName,Make,Model,'Ram(GB)','Uptime(Days)',PageFileDrive,PageFileSizeGB,CurrentUser

                          Write-Output $PSObject
              }#Try
              Catch
              {
                Write-Error -Message $_
              }#catch

          }#Foreach($computer in $ComputerList)

      }#Process
      End
      {
        If($FaliedPCs)
        {
          Write-Output "The following PCs were not responding to pings: $FaliedPCs"
        }
      }#End
}#Get-PCInfo