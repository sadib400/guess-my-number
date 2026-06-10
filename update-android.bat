@echo off
title Guess My Number - Update Android App
color 0A
echo.
echo  ==========================================
echo   Guess My Number - Sync Updated Game
echo  ==========================================
echo.
echo  Copying updated GuessMyNumber.html and syncing...
echo.

copy /Y GuessMyNumber.html www\index.html >nul
if %errorlevel% neq 0 (
    echo  [ERROR] Could not copy GuessMyNumber.html. Make sure www folder exists.
    echo  Run setup-android.bat first if you haven't already.
    pause
    exit /b 1
)
echo  [OK] www\index.html updated.

call npx cap sync android
if %errorlevel% neq 0 (
    echo  [ERROR] Sync failed.
    pause
    exit /b 1
)

echo.
echo  [OK] Done! Rebuild the APK in Android Studio to apply changes.
echo.
pause
