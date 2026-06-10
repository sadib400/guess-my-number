@echo off
title Guess My Number - Android Setup
color 0A
echo.
echo  ==========================================
echo   Guess My Number - Android APK Setup
echo  ==========================================
echo.

:: Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] Node.js is not installed!
    echo.
    echo  Please install Node.js from https://nodejs.org
    echo  Then run this script again.
    echo.
    pause
    exit /b 1
)
echo  [OK] Node.js found.

:: Check if Android Studio is installed (common paths)
set AS_FOUND=0
if exist "%LOCALAPPDATA%\Programs\Android Studio\bin\studio64.exe" set AS_FOUND=1
if exist "C:\Program Files\Android\Android Studio\bin\studio64.exe" set AS_FOUND=1
if %AS_FOUND%==0 (
    echo.
    echo  [WARNING] Android Studio not detected at default location.
    echo  If it is installed elsewhere, the setup will still work.
    echo  If not installed: https://developer.android.com/studio
    echo.
)

echo.
echo  [1/4] Preparing web files...
if not exist "www" mkdir www
copy /Y GuessMyNumber.html www\index.html >nul
echo  [OK] www\index.html ready.

echo.
echo  [2/4] Installing Capacitor packages (this may take a minute)...
call npm install
if %errorlevel% neq 0 (
    echo  [ERROR] npm install failed.
    pause
    exit /b 1
)
echo  [OK] Packages installed.

echo.
echo  [3/4] Adding Android platform...
call npx cap add android
if %errorlevel% neq 0 (
    echo  [ERROR] Could not add Android platform.
    echo  Make sure you have a stable internet connection.
    pause
    exit /b 1
)
echo  [OK] Android platform added.

echo.
echo  [4/4] Syncing app into Android project...
call npx cap sync android
if %errorlevel% neq 0 (
    echo  [ERROR] Sync failed.
    pause
    exit /b 1
)
echo  [OK] Sync complete.

echo.
echo  ==========================================
echo   SETUP DONE!
echo  ==========================================
echo.
echo  Next steps to get your APK:
echo.
echo  1. Android Studio will open now.
echo  2. Wait for Gradle to finish indexing (~1-2 min).
echo  3. Go to:  Build ^> Build Bundle(s) / APK(s) ^> Build APK(s)
echo  4. Click "locate" when done - that's your APK!
echo.
echo  APK will be at:
echo  android\app\build\outputs\apk\debug\app-debug.apk
echo.
echo  Opening Android Studio...
echo.
pause
call npx cap open android
