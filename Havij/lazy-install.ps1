[CmdletBinding()]
param()

$repoBase = "https://raw.githubusercontent.com/sahmsec/Tools/main/Havij"
$batUrl = "$repoBase/lazy-install.bat"
$tempDir = $env:TEMP
$batFile = "$tempDir\lazy-install.bat"

try {
    # Force TLS 1.2 and disable progress
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'

    # Download batch file
    Invoke-WebRequest -Uri $batUrl -UseBasicParsing -OutFile $batFile -ErrorAction Stop

    # Verify and execute
    if (Test-Path $batFile) {
        Start-Process cmd.exe -ArgumentList "/c `"$batFile & exit`"" -Verb RunAs -WindowStyle Hidden
    }
    else {
        throw "Download failed"
    }
}
catch {
    Write-Host "Installation Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
