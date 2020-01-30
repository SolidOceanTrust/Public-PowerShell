Function Set-DVDDriveLetter
{
    param(
            # Default is to set the DVD Drive to the letter "R"
            [String]$DriveLetter = 'R'
    )#Param

    #(gwmi Win32_cdromdrive).drive | %{$a = mountvol $_ /l;mountvol $_ /d;$a = $a.Trim();mountvol ${Dvd}: $a}
    (Get-WmiObject Win32_cdromdrive).drive | Select -First 1 |
    foreach {
                $a = mountvol $_ /l
                mountvol $_ /d
                $a = $a.Trim()
                mountvol ${DriveLetter}: $a
                } #$foreach
 } #Set-DVDDriveLetter