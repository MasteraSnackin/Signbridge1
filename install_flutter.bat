@echo off
REM ============================================================================
REM Flutter Installation Script using Chocolatey
REM 
REM IMPORTANT: This script must be run as Administrator
REM Right-click this file and select "Run as administrator"
REM ============================================================================

echo.
echo ========================================
echo Flutter Installation Script
echo ========================================
echo.
echo This script will install Flutter SDK using Chocolatey.
echo.
echo IMPORTANT: Make sure you are running this as Administrator!
echo.
pause

echo.
echo [1/3] Installing Flutter SDK via Chocolatey...
echo.
choco install flutter -y

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Flutter installation failed!
    echo.
    echo Please try one of these alternatives:
    echo 1. Run this script as Administrator
    echo 2. Manually install from: https://docs.flutter.dev/get-started/install/windows
    echo 3. Use: winget install --id=Google.Flutter -e
    echo.
    pause
    exit /b 1
)

echo.
echo [2/3] Refreshing environment variables...
echo.
refreshenv

echo.
echo [3/3] Verifying Flutter installation...
echo.
flutter --version

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo WARNING: Flutter command not found in current session.
    echo Please close this window and open a NEW Command Prompt.
    echo Then run: flutter --version
    echo.
) else (
    echo.
    echo SUCCESS! Flutter is installed!
    echo.
)

echo.
echo ========================================
echo Installation Complete
echo ========================================
echo.
echo Next steps:
echo 1. Close this window
echo 2. Open a NEW Command Prompt
echo 3. Run: flutter doctor
echo 4. Run: setup_and_build.bat
echo.
pause