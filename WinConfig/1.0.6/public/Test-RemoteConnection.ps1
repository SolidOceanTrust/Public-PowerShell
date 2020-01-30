function Test-RemoteConnection
{
    <#
    .Synopsis
       Tests all methods of connection
    .DESCRIPTION
       This will determine what connection methods are available: Ping,WSMAN,CIM,WMI
    .EXAMPLE
       Test-RemoteConnection -ComputerName localhost
    .EXAMPLE
       Test-RemoteConnection -ComputerName localhost,usriskcalc01 -Test CIM,WSMAN,WSMANAccess,Ping,WMI
    .INPUTS
       ComputerName (accepts array)
    .INPUTS
       Test (Ping,CIM,WSMan,WSManAccess,WMI)
    .OUTPUTS
       Reports of Each Test
    #>

    [CmdletBinding()]
    [Alias('testremote','testconn')]
    [OutputType([PSObject])]
    Param
    (
        # ComputerName param
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        # Test Param
        [ValidateSet("Ping", "WSMan", "WSManAccess", "CIM" , "WMI")]
        $Test
    )#Param

    Begin
    {
        #Assign Tests to variable to 'switch' on later
        $AllTests =@()

        #If the user wants to run a specific test, grab it from the parameter. If nothing specific was specified, then run all of the tests
        if($test)
        {
            Foreach($value in $Test)
            {
                $AllTests += $value
            }#Foreach

        }#If Test

        else {$AllTests = "Ping", "WSMan", "WSManAccess", "CIM" , "WMI"}

        Write-Verbose "Running the following Tests:  $AllTests"

    }#Begin
    Process
    {
        # loop through all the computers in the list!
        foreach($computer in $ComputerName)
        {
            $Properties = @{
                             'Computer'    = $computer.ToString().Trim()
                           }#Properties


            Switch($AllTests)
            {
             "Ping" {
                        $PingTest = (Test-Connection -ComputerName $Computer -Quiet -Count 1) -eq $true
                        $Properties.Add("Ping","$PingTest")
                     }#Ping

             "WSMan" {
                        $WSManTest = try {(Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue) -ne $null } catch {$false}
                        $Properties.Add("WSMan","$WSManTest")
                     }#WSMan

             "WSManAccess" {
                              $WSManAccessTest = try {(Test-WSMan -ComputerName $Computer -Authentication Kerberos -ErrorAction SilentlyContinue) -ne $null} catch {$false}
                              $Properties.Add("WSManAccess","$WSManAccessTest")
                           }#WSManAccess

             "CIM" {
                        $CIMTest =  try {(Get-CimInstance -Query "SELECT Name From Win32_ComputerSystem" -ComputerName $Computer -ErrorAction SilentlyContinue -OperationTimeoutSec 1) -ne $null} catch {$false}
                        $Properties.Add("CIM","$CIMTest")
                   }#CIM

             "WMI" {
                        $WMITest = try {(Get-WmiObject -Query "SELECT Name From Win32_ComputerSystem" -ComputerName $Computer -ErrorAction SilentlyContinue) -ne $null} catch {$false}
                        $Properties.Add("WMI","$WMITest")
                   }

            }#Switch


            $Object = New-Object -TypeName psobject -Property $Properties

            $Object = $Object | Select-Object Computer,Ping,WSMan,WSManAccess,CIM,WMI

            Write-Output $Object

            Remove-Variable PingTest -Force -ErrorAction SilentlyContinue
            Remove-Variable WSManTest -Force -ErrorAction SilentlyContinue
            Remove-Variable WSManAccessTest -Force -ErrorAction SilentlyContinue
            Remove-Variable CIMTest -Force -ErrorAction SilentlyContinue
            Remove-Variable WMITest -Force -ErrorAction SilentlyContinue

        }#Foreach

    }#Process

    End
    {
        Write-Verbose "All Computers Tested....Exiting"
    }#End

}#function Test-RemoteConnection