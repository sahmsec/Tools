# Requires -Version 5.1
[CmdletBinding()]
param()

$repoBase = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij-1.2"
$batUrl = "$repoBase/ez-install.bat"

# Use current script execution directory instead of TEMP
$currentDir = Get-Location
$batFile = Join-Path -Path $currentDir -ChildPath "ez-install-$(Get-Date -Format 'yyyyMMddHHmmss').bat"

try {
    # Secure download with TLS 1.2+
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'

    # Download the batch file
    Write-Host "Downloading installation package..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $batUrl -UseBasicParsing -OutFile $batFile -ErrorAction Stop

    # Verify download
    if (-not (Test-Path $batFile)) {
        throw "Download failed - file not found"
    }

    Write-Host "`nDownloaded to: $batFile" -ForegroundColor Cyan
    Write-Host "SHA256: $(Get-FileHash $batFile -Algorithm SHA256 | Select-Object -ExpandProperty Hash)" -ForegroundColor Cyan

    # Run the .bat file with elevation
    Write-Host "Starting secure installation..." -ForegroundColor Green
    Start-Process cmd.exe -ArgumentList "/c `"$batFile`"" -Verb RunAs

    exit

} catch {
    Write-Host "`n[ERROR] Installation failed: $_" -ForegroundColor Red
    exit 1
}
