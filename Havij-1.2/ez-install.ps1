# Requires -Version 5.1
[CmdletBinding()]
param()

$batUrl = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij-1.2/ez-install.bat"
$currentDir = Get-Location
$batFile = Join-Path -Path $currentDir -ChildPath "ez-install.bat"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'
    
    Write-Host "Downloading installation package..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $batUrl -UseBasicParsing -OutFile $batFile -ErrorAction Stop

    if (-not (Test-Path $batFile)) {
        throw "Download failed"
    }

    Write-Host "`nStarting installation..." -ForegroundColor Green
    Start-Process cmd.exe -ArgumentList "/c `"$batFile`"" -Verb RunAs
    exit
} catch {
    Write-Host "`n[ERROR] Failed: $_" -ForegroundColor Red
    exit 1
}
