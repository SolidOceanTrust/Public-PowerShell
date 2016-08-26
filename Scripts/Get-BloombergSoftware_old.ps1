<#
# Bloomberg Professtional Full
http://bdn-ak.bloomberg.com/software/trv/sotrt11082016.exe

# Bloomberg Professtional Upgrade (all components)
http://bdn-ak.bloomberg.com/software/trv/bupd11082016.exe

# Bloomberg Professtional Update (App Only)
http://bdn-ak.bloomberg.com/software/trv/upgr11082016.exe

#$BuildDay | foreach{
#        "$BuildMonth$_$BuildYear"}

#web http://bdn-ak.bloomberg.com/software/trv/sotrt11082016.exe
#gen http://bdn-ak.bloomberg.com/software/trv/sotrt11082016.exe

"$BaseUrl$("$BuildMonth$_$BuildYear")$AppSuffix"

        # Write-Output "Trying BBerg Build at $BuildFileName"
        # "$BaseUrl$("$AppType$BuildMonth$day$BuildYear.exe")"

#>
<#
.Synopsis
   Downloads Bloombergs Versions
.DESCRIPTION
   Downloads Bloomberg Software from the pages, can choose between upgrade,update,new install
.EXAMPLE
   Download-BloombergVersions -version update -version recent -downloadpath c:\Software
.EXAMPLE
   Download-BloombergVersions -version "new install" -version 11/2016 -downloadpath c:\Software
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
[CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
Param(


      )#param
$AppTypes = ("sotrt","bupd","upgr")
$BuildYear = (Get-Date).Year
#$BuildMonth = (Get-Date).Month
$BuildMonth = (Get-Date 11/1/2016).Month
$BuildMonthName = (Get-Date 11/1/2016 -format MMM)
#$BuildName = (Get-Date).Month
$BuildName = $BuildMonth
#$BuildDay = ("06","07","08","09")
$BuildDay = ("08","09")
$BaseDownloadPath = "D:\BloombergSoftware"

If((Test-Path $BaseDownloadPath) -eq $false)
{
    New-Item -Type Directory -Path $BaseDownloadPath -Force
}
else {

        $BaseUrl = "http://bdn-ak.bloomberg.com/software/trv/"

        Foreach($AppType in $AppTypes)
        {
            foreach($day in $BuildDay)
            {

                $BuildFileName = $("$AppType$BuildMonth$day$BuildYear.exe")

                $DownloadLocation = switch ($AppType) {
                    "sotrt" { "$BaseDownloadPath\FullInstall\$("$buildMonthName $day $buildYear")"}
                    "bupd"  { "$BaseDownloadPath\Upgrade\$buildMonthName $day $buildYear" }
                    "upgr"  { "$BaseDownloadPath\AppOnlyUpdate\$buildMonthName $day $buildYear" }
                    Default {"This should never be evaluated. I'm ok with this failiing. Try and find this DIR"}
                }

                Write-Output "$DownloadLocation"
                try {
                        New-Item -Path $DownloadLocation -Force -ItemType Directory
                        $FinalDownloadLocation = (Join-path $DownloadLocation $BuildFileName)
                        #Invoke-WebRequest -uri $("$BaseUrl$BuildFileName") -erroraction Stop -passthru -outfile D:\BloombergSoftware -UseBasicParsing
                        $wc = New-Object System.Net.WebClient
                        $wc.DownloadFile("$BaseUrl$BuildFileName", $FinalDownloadLocation)
                     }
                catch {"Bad url:  $BaseUrl$BuildFileName"}

            }#foreach($day in $BuildDay)
        }#Foreach($AppType in $AppTypes)
}#Else
