<#
.SYNOPSIS
    Installs the Puppet Agent on a remote server
.DESCRIPTION
    Installs the Puppet Agent on a remote server
.EXAMPLE
    Install-Puppet -ComputerName server1
    Install-Puppet -ComputerName s1,s2
.INPUTS
    String[] ComputerName
    String PuppetServer
.OUTPUTS
.NOTES
    YOU ARE RUNNING THIS AS AN ADMINISTRATOR RIGHT?
#>

function Install-Puppet {
    [CmdletBinding()]
    param (
        [Alias('pc','comp')]
        [ValidateScript({ (Test-Connection -ComputerName $_ -count 1 -Quiet) -eq $true })]
        [String[]] $computerName,

        [String] $PuppetServer = 'puppet.homelab.com'
    )
    
    begin {
        # Validate that you have access to the computer list over PSRemoting
        $good = @()
        $bad  = @()
        foreach ($server in $computerName) {
            try {
                $test = Test-WSMan -ComputerName $server -Authentication Kerberos -ErrorAction Stop
                if($test) {$good += $server}
            }
            catch {
                Write-Host "Server [$server] was not reachable via PSRemoting. Do you have access?"
                Write-Host "Server [$server] will be skipped"
                $bad += $server
            }
        }
    }
    
    process {
        # Loop Through the good list of computers and install Puppet
        foreach ($s in $good) {
            Get-PSSession | Disconnect-PSSession | Remove-PSSession
            $session = New-PSSession -computerName $s
            Invoke-Command -Session $session -ScriptBlock {
                Write-Host "Architecture " $ENV:PROCESSOR_ARCHITECTURE
                $url = "https://$using:PuppetServer`:8140/packages/current/windows-i386/puppet-agent-x86.msi"
    
                if ( $ENV:PROCESSOR_ARCHITECTURE.EndsWith("64") ) {
                    $url = "https://$using:PuppetServer`:8140/packages/current/windows-x86_64/puppet-agent-x64.msi"
                }
    
                $target = join-path -path $env:TEMP -childpath "puppet-install.msi"
                $log = join-path -path $env:TEMP -childpath "puppet-install.log"
    
                if ( Test-Path $target )
                {
                    del $target
                }
    
                Write-Host "Downloading " $url
    
                # Ignore SSL Errors since Puppet is self signed
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
                (New-Object System.Net.WebClient).DownloadFile($url, $target)
                #Invoke-WebRequest -Uri $url -OutFile $target
    
                Write-Host "Installing " $target
                msiexec /qn /norestart /i $target /L*V $log PUPPET_MASTER_SERVER="$using:PuppetServer"
            }
        
        #Get-PSSession $session | Remove-PSSession -Verbose
        }
    }
    
    end {
    }
}