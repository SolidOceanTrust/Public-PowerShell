Function Connect-ToExchangeOnline
{
    <#
    .Synopsis
       Connects to Exchange Online in the cloud
    .DESCRIPTION
       Long description
    .EXAMPLE
       Example of how to use this cmdlet
    .EXAMPLE
       Connect-toExchangeOnline
    #>

    [CmdletBinding()]
    [Alias('conmsol','eop')]
    Param
    ()
    # http://powershell.office.com/scenarios/how-to-connect-to-o365
    #https://technet.microsoft.com/en-us/library/jj984289(v=exchg.160).aspx
        try{
                $Credential = Get-Credential -Message "Enter your Exchange Online Credentials"

                Import-Module MSOnline

                Connect-MsolService -Credential $Credential


                $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
                Import-PSSession $Session
                Write-Verbose "Connection Established!!!"
            }
        catch{ "Couldn't connect or authenticate to exchange online" }

} #Function Connect-ToExchangeOnline