# https://www.powershelladmin.com/w/images/8/86/Get-FolderSize.ps1.txt
function get-foldersize2 {
    [CmdletBinding()]
    [Alias('size2')]
    param (
        [Parameter(ParameterSetName = "Path", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('Name', 'FullName')]
        [string[]] $Path,
		
		[Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, Position = 0)]
		[string[]] $LiteralPath
    ) 

    # New Code
	if ($PSCmdlet.ParameterSetName -eq "Path") {
		$Paths = @(Resolve-Path -Path $Path | Select-Object -ExpandProperty ProviderPath -ErrorAction SilentlyContinue)
    } else {
        $Paths = @(Get-Item -LiteralPath $LiteralPath | Select-Object -ExpandProperty FullName -ErrorAction SilentlyContinue)
    }
	foreach ($p in $Paths) {
		Write-Verbose -Message "Processing path '$p'. $([datetime]::Now)."
		if (-not (Test-Path -LiteralPath $p -PathType Container)) {
			Write-Warning -Message "$p does not exist or is a file and not a directory. Skipping."
			continue
		}
		$ErrorActionPreference = 'Stop'
		$FSO = New-Object -ComObject Scripting.FileSystemObject -ErrorAction Stop
		try {
                $StartFSOTime = [datetime]::Now
                $TotalBytes = $FSO.GetFolder($p).Size
                $EndFSOTime = [datetime]::Now
                if ($null -eq $TotalBytes) {
					Write-Warning -Message "Failed to retrieve folder size for path '$p': $($Error[0].Exception.Message)."
                }
            }
            catch {
                if ($_.Exception.Message -like '*PERMISSION*DENIED*') {
					Write-Warning "Failed to process path '$p' due to a permission denied error: $($_.Exception.Message)"
                }
                Write-Warning -Message "Encountered an error while processing path '$p': $($_.Exception.Message)"
                continue
            }
            $ErrorActionPreference = 'Continue'
            New-Object PSObject -Property @{
                Path = $p
                TotalBytes = [decimal] $TotalBytes
                TotalMBytes = [math]::Round(([decimal] $TotalBytes / 1MB), $Precision)
                TotalGBytes = [math]::Round(([decimal] $TotalBytes / 1GB), $Precision)
                BytesFailed = $null
                DirCount = $null
                FileCount = $null
                DirFailed = $null
                FileFailed  = $null
                TimeElapsed = [math]::Round(([decimal] ($EndFSOTime - $StartFSOTime).TotalSeconds), $Precision)
                StartedTime = $StartFSOTime
                EndedTime = $EndFSOTime
            }
	}
}