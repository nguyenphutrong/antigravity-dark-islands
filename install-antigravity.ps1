# Backward-compatible entrypoint.
# Main Antigravity installer is install.ps1.

param()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainInstaller = Join-Path $scriptDir "install.ps1"

if (-not (Test-Path $mainInstaller)) {
    Write-Host "install.ps1 not found." -ForegroundColor Red
    exit 1
}

& $mainInstaller
