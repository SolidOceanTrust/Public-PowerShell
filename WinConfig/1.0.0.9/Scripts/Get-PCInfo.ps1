Function Get-PCInfo
{
    [CmdletBinding()]
    [Alias('pcinfo','pci')]
    [OutputType([String])]

    Param(
            [Alias('cn','pc')]
            [string[]]$ComputerList = $env:COMPUTERNAME
          )#param


      begin
      {
        Write-Verbose "[Begin] Checking All computers for Status"
        Write-Verbose "[Begin] Supplied Computers: $computerList "

        $ComputerList | ForEach-Object {
            if((Test-Connection -Quiet -Count 1 -ComputerName $_) -eq $true)
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
                        $HWInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer

                        $CurrentUser = try{(Get-WmiObject -Class Win32_Process -computer $Computer -ErrorAction Stop| Where{$_.name -like '*explorer*'}).GetOwner().User | Select -Unique} catch {"none"}

                        $ServiceCheck = Get-Service -ComputerName $computer -Name ThinKioskMachineService -ErrorAction SilentlyContinue
                        $ProcessCheck = Get-Process -ComputerName $computer -Name ThinKioskMachineService -ErrorAction SilentlyContinue

                          if($ServiceCheck -or $ProcessCheck)
                          {
                              $IsThinKioskPC = 'Yes'
                          }#if
                          else {$IsThinKioskPC = "No"}

                        $Uptime = (New-Timespan -Start (($upt = Get-WmiObject -Query 'Select LastBootupTime FROM Win32_Operatingsystem' -ComputerName $Computer)).ConvertToDateTime($upt.LastBootUpTime) ).Days

                        $Object = @{
                                      'ComputerName'  = $Computer.ToUpper()
                                      'Make'          = $HWInfo.Manufacturer.trim()
                                      'Model'         = $HWInfo.Model.Trim()
                                      'RAM(GB)'       = ($HWInfo.TotalPhysicalMemory /1GB) -as [int]
                                      'CurrentUser'   = $CurrentUser
                                      'IsThinKioskPC'  = $IsThinKioskPC
                                      'Uptime(Days)'  = $Uptime
                          }#Object

                          $PSObject = New-Object -TypeName PSObject -Property $Object

                          $PSObject = $PSObject | Select ComputerName,Make,Model,'Ram(GB)','Uptime(Days)',CurrentUser,IsThinKioskPC

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