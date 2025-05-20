# Requires -Version 5.1
[CmdletBinding()]
param()

$repoBase = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij-1.2"
$batUrl = "$repoBase/ez-install.bat"

# Get desktop path dynamically
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Define AWS folder path on desktop
$awsFolder = Join-Path -Path $desktopPath -ChildPath "AWS"

# Create AWS folder if it does not exist
if (-not (Test-Path -Path $awsFolder -PathType Container)) {
    New-Item -Path $awsFolder -ItemType Directory | Out-Null
}

# Define full path for the batch file inside the AWS folder
$batFile = Join-Path -Path $awsFolder -ChildPath "ez-install-$(Get-Date -Format 'yyyyMMddHHmmss').bat"

try {
    # Use TLS 1.2+
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Suppress progress display
    $oldProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    Write-Host "Downloading installation package to $awsFolder ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $batUrl -UseBasicParsing -OutFile $batFile -ErrorAction Stop

    # Restore progress preference
    $ProgressPreference = $oldProgressPreference

    # Confirm file download
    if (-not (Test-Path -Path $batFile)) {
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
