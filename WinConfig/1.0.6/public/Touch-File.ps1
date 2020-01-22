function Touch-File {
    [CmdletBinding()]
    [Alias("touch")]
    param (
        $fileName
    )
    begin {
        $fileExists = Test-Path -Path $fileName
        $currentTime = Get-Date
    }
    process {
        switch ($fileExists) {
            $true { Set-ItemProperty -Path $fileName -Name LastWriteTime -Value $currentTime }
            $false { New-Item -Path $fileName }
            Default {Write-Host -fore Yellow " How did we get to Default with a bool????"}
        }
    }
    end {
    }
}