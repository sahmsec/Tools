[CmdletBinding()]
param()

$repoBase = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij"
$batUrl = "$repoBase/lazy-install.bat"
$tempDir = $env:TEMP
$batFile = "$tempDir\lazy-install-$(Get-Date -Format 'yyyyMMddHHmmss').bat"

try {
    # Enforce modern security protocols
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download batch file
    Write-Host "Downloading security toolkit..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $batUrl -UseBasicParsing -OutFile $batFile -ErrorAction Stop

    # Verify download
    if (-not (Test-Path $batFile)) {
        throw "Download verification failed"
    }

    # Security verification prompt
    Write-Host "`n[Security Check]" -ForegroundColor Yellow
    Write-Host "File saved to: $batFile"
    Write-Host "Optional: Verify hash before proceeding"
    
    $confirmation = Read-Host "`nProceed with installation? (Y/N)"
    if ($confirmation -ne 'Y') { exit }

    # Execute with elevation
    Start-Process cmd.exe -ArgumentList "/c `"$batFile`"" -Verb RunAs

} catch {
    Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
