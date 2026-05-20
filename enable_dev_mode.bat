@echo off
echo ==========================================
echo  Enable Windows Developer Mode
echo ==========================================
echo.
echo This script will enable Developer Mode required for Flutter symlink support.
echo.
pause

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 1

if %errorlevel% == 0 (
    echo.
    echo SUCCESS! Developer Mode enabled.
    echo Please restart your computer for changes to take effect.
    echo.
) else (
    echo.
    echo FAILED! Please run this script as Administrator.
    echo Right-click the file and select "Run as administrator".
    echo.
)

pause
