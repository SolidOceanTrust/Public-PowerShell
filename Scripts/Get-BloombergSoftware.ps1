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

$AppTypes = @("sotrt","bupd","upgr")
$BuildYear = (Get-Date).Year
$BuildMonth = (Get-Date).Month
$BuildMonthName = (Get-Date -format MMM)
$BuildName = (Get-Date).Month
$BuildDay = ("06","07","08","09")
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
                    "sotrt" { "$BaseDownloadPath\FullInstall\$buildMonthName $day $buildYear"}
                    "bupd"  { "$BaseDownloadPath\Upgrade\$buildMonthName $day $buildYear" }
                    "upgr"  { "$BaseDownloadPath\AppOnlyUpdate\$buildMonthName $day $buildYear" }
                    Default {"This should never be evaluated. I'm ok with this failiing. Try and find this DIR"}
                }

                Write-Output "$DownloadLocation"
                try {Invoke-WebRequest $("$BaseUrl$BuildFileName") -erroraction Stop -outfile (Join-path $DownloadLocation $BuildFileName) }
                catch {"Bad url:  $BaseUrl$BuildFileName"}

            }#foreach($day in $BuildDay)
        }#Foreach($AppType in $AppTypes)
}#Else
