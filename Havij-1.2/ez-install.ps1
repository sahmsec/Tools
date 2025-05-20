# Requires -Version 5.1
[CmdletBinding()]
param()

$repoBase = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij-1.2"
$batUrl = "$repoBase/ez-install.bat"

# Get desktop path dynamically
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Create AWS folder on desktop if it doesn't exist
$awsFolder = Join-Path -Path $desktopPath -ChildPath "AWS"
if (-not (Test-Path $awsFolder)) {
    New-Item -Path $awsFolder -ItemType Directory | Out-Null
}

# Set path for the .bat file inside the AWS folder
$batFile = Join-Path -Path $awsFolder -ChildPath "ez-install-$(Get-Date -Format 'yyyyMMddHHmmss').bat"

try {
    # Use TLS 1.2+
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Suppress progress for cleaner output
    $oldProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    Write-Host "Downloading installation package..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $batUrl -UseBasicParsing -OutFile $batFile -ErrorAction Stop

    # Restore original progress preference
    $ProgressPreference = $oldProgressPreference

    if (-not (Test-Path $batFile)) {
        throw "Download failed: file not found at $batFile"
    }

    Write-Host "`nDownloaded to: $batFile" -ForegroundColor Cyan
    $hash = Get-FileHash $batFile -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    Write-Host "SHA256: $hash" -ForegroundColor Cyan

    Write-Host "Starting secure installation..." -ForegroundColor Green
    Start-Process cmd.exe -ArgumentList "/c `"$batFile`"" -Verb RunAs -Wait

    exit

} catch {
    Write-Host "`n[ERROR] Installation failed: $_" -ForegroundColor Red
    exit 1
}
