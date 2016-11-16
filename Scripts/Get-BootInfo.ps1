Function Get-BootInfo
{
    [cmdletbinding()]
    Param
    (
        [ValidateScript({Test-Connection -Count 1 -Quiet -ComputerName $_})]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )#Param

    Foreach ($computer in $ComputerName)
    {
        try
        {
            $RebootHash = @{
	                    LogName = 'System'
	                    ID = '6009','6006','6005','1074'
                        }#Hash

             $BootInfoRaw = Get-WinEvent -FilterHashtable $RebootHash -computername $computer

             Foreach($record in $BootInfoRaw)
             {
                  $Cause = switch($record.ID)
                  {
                   # 6005 = BootUp
            # 6006 = Graceful Shutdown
            # 6009 = StartUp
            # 1074 = Shutdown
                    '6005' {"BootUp"}
                    '6006' {"Graceful Shutdown"}
                    '6009' {"StartUp"}
                    '1074' {"ShutDown"}
                  }#switch 
                  $Properties = @{
                  
                    DateTime = $record.TimeCreated
                    Id       = $record.ID
                    Message  = @($record.Message.ToString())
                    Cause    = $Cause

                  }#Properties
                  
                  $object = New-Object -TypeName psobject -Property $Properties
                  $object = $object | Select-Object DateTime,ID,Cause,Message
                  Write-Output $object  

             }#Foreach

        } #try
        catch
        {
            Write-Host "Other exception"
            Write-Error -Exception $_
        }

    }#Foreach
}#Function