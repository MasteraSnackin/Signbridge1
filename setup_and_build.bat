@echo off
REM SignBridge - Automated Setup and Build Script for Windows
REM This script will guide you through installing Flutter and building the APK

echo ========================================
echo SignBridge - Setup and Build Script
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed!
    echo.
    echo Please install Flutter first:
    echo 1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
    echo 2. Extract to C:\flutter (or your preferred location)
    echo 3. Add C:\flutter\bin to your PATH environment variable
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter is installed
flutter --version
echo.

REM Check Flutter doctor
echo Checking Flutter environment...
flutter doctor
echo.

echo ========================================
echo Starting Build Process
echo ========================================
echo.

REM Clean previous builds
echo [1/6] Cleaning previous builds...
flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter clean failed!
    pause
    exit /b 1
)
echo [OK] Clean complete
echo.

REM Get dependencies
echo [2/6] Installing dependencies...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to get dependencies!
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Run code analysis
echo [3/6] Running code analysis...
flutter analyze
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Code analysis found issues (continuing anyway)
)
echo.

REM Run tests
echo [4/6] Running tests...
flutter test
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Some tests failed (continuing anyway)
)
echo.

REM Build debug APK
echo [5/6] Building debug APK...
flutter build apk --debug
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Debug build failed!
    pause
    exit /b 1
)
echo [OK] Debug APK built successfully
echo.

REM Build release APK
echo [6/6] Building release APK (split by ABI)...
flutter build apk --release --split-per-abi
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Release build failed!
    pause
    exit /b 1
)
echo [OK] Release APK built successfully
echo.

REM Show build results
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK files are located in:
echo build\app\outputs\flutter-apk\
echo.
dir /B build\app\outputs\flutter-apk\*.apk
echo.

REM Generate checksums
echo Generating checksums...
cd build\app\outputs\flutter-apk
certutil -hashfile app-arm64-v8a-release.apk SHA256 > checksums.txt
certutil -hashfile app-armeabi-v7a-release.apk SHA256 >> checksums.txt
certutil -hashfile app-x86_64-release.apk SHA256 >> checksums.txt
cd ..\..\..\..
echo [OK] Checksums generated
echo.

echo ========================================
echo Next Steps:
echo ========================================
echo 1. Test the APK on an Android device
echo 2. Install using: adb install build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo 3. Or transfer the APK to your device and install manually
echo.
echo Note: This build uses mock Cactus SDK implementations.
echo For full functionality, integrate the real Cactus SDK.
echo.
pause