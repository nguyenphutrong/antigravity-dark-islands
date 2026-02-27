@echo off
REM Backward-compatible launcher.
REM Main installer is install.ps1.

echo Islands Dark Theme - Antigravity Installer
echo ==========================================
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0install.ps1"

pause
