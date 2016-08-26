function Enable-CitrixReceiverLogging
{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='Medium')]
    
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [Alias("cn")] 
        #[ValidateScript({ (Test-WSMan -ComputerName $_ -Authentication Kerberos) -ne $null })]
        [String[]]$ComputerName = $env:COMPUTERNAME

    )#Param

    Begin
    {
            #Validate
            $good = @()
            $bad  = @()

            #Validate Computers for Ping,WSMan
            foreach($comp in $ComputerName)
            {
                #test
                if((Test-Connection -ComputerName $comp -Count 1 -Quiet) -and (Test-WSMan -ComputerName $comp -Authentication Kerberos -ErrorAction SilentlyContinue)-ne $null)
                {
                    $good += $comp
                }#if
                else { $bad += $comp } #else
            }#foreach  

    }#Begin
    Process
    {
        $EnableCitrixReceiverLoggingScriptBlock = {

                $CitrixRegBase64 = 'HKLM:\SOFTWARE\Wow6432Node\Citrix'

                # Enable Reciever Logging
                Set-ItemProperty -Path $CitrixRegBase64 -Name ReceiverVerboseTracingEnabled -Value 1 -Force

                # Enable Trace level logging of the Authentication Manager Service
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Authmanager) -Name LoggingMode -Value Verbose -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Authmanager) -Name TracingEnabled -Value True  -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Authmanager) -Name SDKTracingEnabled -Value True  -Force

                # Enable Receiver Logging - Self-Service Plugin
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Dazzle) -Name Tracing -Value True -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Dazzle) -Name AuxTracing -Value True -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Dazzle) -Name DefaultTracingConfiguration -Value " global all –detail” -Force

        }#$EnableCitrixReceiverLoggingScriptBlock

        Foreach ($comp1 in $good)
        {
            
            if($comp1 -eq $env:COMPUTERNAME)
            {
                Write-Verbose "Running Locally: $comp1"
                $EnableCitrixReceiverLoggingScriptBlock
            }#if
            else {
                    Write-Verbose "Running Remote: $comp1"
                    Invoke-Command -ComputerName $comp1 -ScriptBlock $EnableCitrixReceiverLoggingScriptBlock
                 }#else

        }#foreach

    }#Process
    End
    {
        if($bad.count -ne 0)
        {
            Write-Output "The following machines either did not ping or did not allow ps remoting  `n `n $bad"
        }#if
        else {Write-Output "Operation Complete" }
    }#End
}# Function

function Disable-CitrixReceiverLogging
{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='Medium')]
    
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [Alias("cn")] 
        #[ValidateScript({ (Test-WSMan -ComputerName $_ -Authentication Kerberos) -ne $null })]
        [String[]]$ComputerName = $env:COMPUTERNAME

    )#Param

    Begin
    {
            #Validate
            $good = @()
            $bad  = @()

            #Validate Computers for Ping,WSMan
            foreach($comp in $ComputerName)
            {
                #test
                if((Test-Connection -ComputerName $comp -Count 1 -Quiet) -and (Test-WSMan -ComputerName $comp -Authentication Kerberos -ErrorAction SilentlyContinue)-ne $null)
                {
                    $good += $comp
                }#if
                else { $bad += $comp } #else
            }#foreach  

    }#Begin
    Process
    {
        $DisableCitrixReceiverLoggingScriptBlock = {

                # Disable Reciever Logging
                Set-ItemProperty -Path $CitrixRegBase64 -Name ReceiverVerboseTracingEnabled -Value 0 -Force

                # Disable Trace level logging of the Authentication Manager Service
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Authmanager) -Name LoggingMode -Value Normal -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Authmanager) -Name TracingEnabled -Value False  -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Authmanager) -Name SDKTracingEnabled -Value False  -Force

                # Disable Receiver Logging - Self-Service Plugin
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Dazzle) -Name Tracing -Value False -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Dazzle) -Name AuxTracing -Value False -Force
                Set-ItemProperty -Path (join-path $CitrixRegBase64 Dazzle) -Name DefaultTracingConfiguration -Value " global all –detail” -Force

        }#$DisableCitrixReceiverLoggingScriptBlock

        Foreach ($comp1 in $good)
        {
            
            if($comp1 -eq $env:COMPUTERNAME)
            {
                Write-Verbose "Running Locally: $comp1"
                $DisableCitrixReceiverLoggingScriptBlock
            }#if
            else {
                    Write-Verbose "Running Remote: $comp1"
                    Invoke-Command -ComputerName $comp1 -ScriptBlock $DisableCitrixReceiverLoggingScriptBlock
                 }#else

        }#foreach

    }#Process
    End
    {
        if($bad.count -ne 0)
        {
            Write-Output "The following machines either did not ping or did not allow ps remoting  `n `n $bad"
        }#if
        else {Write-Output "Operation Complete" }
    }#End
}# Function