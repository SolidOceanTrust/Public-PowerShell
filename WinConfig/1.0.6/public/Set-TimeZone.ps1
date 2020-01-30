Function Set-TimeZone {

    [CmdletBinding()]
    Param
        (
            # TimeZone Param help description
            [Parameter(Mandatory=$true,Position=0)]
            [ValidateScript( {
                                #"Borrowed" From http://powershell.com/cs/blogs/tips/archive/2013/08/13/changing-current-time-zone.aspx
                                [system.timezoneinfo]::GetSystemTimeZones() |
                                Where-Object { $_.ID -like "*$_*" -or $_.DisplayName -like "*$_*" }
                              }
                            ) ] #ValidateScript
            [String]$TimeZone
        )

        try {tzutil /s $TimeZone}
        catch{"Error: Not a valid timezone. Please use tzutil /l to get the correct Time Zone Name"}

} #Set-TimeZone