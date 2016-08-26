Function Connect-Exchange
{
    <#
    .Synopsis
     Stolen from Paul Cunningham
    .DESCRIPTION
       http://exchangeserverpro.com/powershell-function-to-connect-to-exchange-on-premises/
    .EXAMPLE
       Connect-Exchange -URL $exchangeServer
    #>
        [CmdletBinding()]
        [Alias('conex','exchange','exch')]
        param(
        [Parameter( Mandatory=$true)]
        [string]$URL=""
    )

    $Credentials = Get-Credential -Message "Enter your Exchange admin credentials"

    $ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$URL/PowerShell/ -Authentication Kerberos -Credential $Credentials

    Import-PSSession $ExOPSession

} #Function Connect-Exchange