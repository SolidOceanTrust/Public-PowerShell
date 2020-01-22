function get-foldersize {
    [CmdletBinding()]
    [Alias('size')]
    param (
        $folderpath = $($pwd.path),
        #[ValidateScript({ $ping = New-Object System.Net.Networkinformation.ping; ($ping.Send("$_",1000).Status) -eq "Success"})]
        $computer
    ) 

    if ($computer) {
        try { 
                $comp_check = Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction Stop
                if(-not $comp_check) {
                    Throw "Unable to access $computer"
                }
        }
        catch {Throw "Unable to ping $computer"}
        try {
            $folderpath_to_unc = ($folderpath).Replace(":","$")
            $path_check = Test-path "\\$computer\$folderpath_to_unc"
            Write-Verbose "$folderpath_to_unc"
            Write-Verbose "Computer: $computer"
            if($path_check -eq $False) {
                Throw "Unable to find $folderpath_to_unc on $computer"
            }
            else {
                $size = (Get-ChildItem -Recurse "\\$computer\$folderpath_to_unc" -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
                Write-Verbose "Size: $size"

                if($size/1MB -ge 1000) {
                    Write-Output ("{0:N2} GB" -f ($size / 1GB) )
                }
                else {
                    Write-Output ("{0:N2} MB" -f ($size / 1MB) )
                }
            }
        }
        catch {Throw "unable to access $folderpath on $computer : `"\\$computer\$folderpath_to_unc`" "}
    }
    else {
        $path_check = Test-path $folderpath -ErrorAction Stop
        if($path_check -eq $False) {
            Throw "Unable to find $folderpath"
            break
        }
        else {
            try {
                $size = (Get-ChildItem -Recurse $folderpath -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
            }
            catch { Throw "Error: unable to access $folderpath "}
        }
        if($size/1MB -ge 1000) {
            Write-Output ("{0:N2} GB" -f ($size / 1GB) )
        }
        else {
            Write-Output ("{0:N2} MB" -f ($size / 1MB) )
        }
    }
}