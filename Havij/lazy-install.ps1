[CmdletBinding()]
param()

$repoBase = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij"
$batUrl = "$repoBase/lazy-install.bat"
$tempDir = $env:TEMP
$batFile = "$tempDir\lazy-install.bat"

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

    # Automatic execution with elevation
    Start-Process cmd.exe -ArgumentList "/c `"$batFile & exit`"" -Verb RunAs -WindowStyle Hidden

} catch {
    Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
