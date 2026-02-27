# Islands Dark Theme Installer for Antigravity (Windows)

param()

$ErrorActionPreference = "Stop"

Write-Host "Islands Dark Theme Installer for Antigravity (Windows)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

function Get-AntigravityCli {
    $cli = Get-Command "antigravity" -ErrorAction SilentlyContinue
    if ($cli) { return $cli.Source }

    $aliasCli = Get-Command "agy" -ErrorAction SilentlyContinue
    if ($aliasCli) { return $aliasCli.Source }

    $candidates = @(
        "$env:USERPROFILE\.antigravity\antigravity\bin\antigravity.cmd",
        "$env:USERPROFILE\.antigravity\antigravity\bin\antigravity.exe",
        "$env:LOCALAPPDATA\Programs\Antigravity\bin\antigravity.cmd",
        "$env:LOCALAPPDATA\Programs\Antigravity\bin\antigravity.exe",
        "$env:ProgramFiles\Antigravity\bin\antigravity.cmd",
        "$env:ProgramFiles\Antigravity\bin\antigravity.exe",
        "${env:ProgramFiles(x86)}\Antigravity\bin\antigravity.cmd",
        "${env:ProgramFiles(x86)}\Antigravity\bin\antigravity.exe"
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    return $null
}

$antigravityCli = Get-AntigravityCli
if (-not $antigravityCli) {
    Write-Host "Error: Antigravity CLI not found." -ForegroundColor Red
    Write-Host "Install Antigravity and ensure 'antigravity' command is available."
    exit 1
}

Write-Host "Antigravity CLI found: $antigravityCli" -ForegroundColor Green

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "Step 1: Installing Islands Dark theme extension..."

$extRoot = "$env:USERPROFILE\.antigravity\extensions"
$extDir = Join-Path $extRoot "bwya77.islands-dark-1.0.0"

if (Test-Path $extDir) {
    Remove-Item -Recurse -Force $extDir
}

New-Item -ItemType Directory -Path $extDir -Force | Out-Null
Copy-Item "$scriptDir\package.json" "$extDir\" -Force
Copy-Item "$scriptDir\themes" "$extDir\themes" -Recurse -Force

if (Test-Path "$extDir\themes") {
    Write-Host "Theme extension installed to $extDir" -ForegroundColor Green
} else {
    Write-Host "Failed to install theme extension" -ForegroundColor Red
    exit 1
}

$extJsonPath = Join-Path $extRoot "extensions.json"
if (Test-Path $extJsonPath) {
    Remove-Item $extJsonPath -Force
    Write-Host "Cleared extensions.json (Antigravity will rebuild it)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Installing Custom UI Style extension..."
try {
    & $antigravityCli --install-extension subframe7536.custom-ui-style --force | Out-Null
    Write-Host "Custom UI Style extension installed" -ForegroundColor Green
} catch {
    Write-Host "Could not install Custom UI Style extension automatically" -ForegroundColor Yellow
    Write-Host "   Please install it manually from Antigravity Extensions"
}

Write-Host ""
Write-Host "Step 3: Installing Bear Sans UI fonts..."
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $fontDir)) {
    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
}

try {
    $fonts = Get-ChildItem "$scriptDir\fonts\*.otf"
    foreach ($font in $fonts) {
        Copy-Item $font.FullName $fontDir -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Fonts installed" -ForegroundColor Green
} catch {
    Write-Host "Could not install fonts automatically" -ForegroundColor Yellow
    Write-Host "   Install .otf files from the 'fonts' folder manually"
}

Write-Host ""
Write-Host "Step 4: Applying Antigravity settings..."
$settingsDir = "$env:APPDATA\Antigravity\User"
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}

$settingsFile = Join-Path $settingsDir "settings.json"
if (Test-Path $settingsFile) {
    $backupFile = "$settingsFile.pre-islands-dark"
    Copy-Item $settingsFile $backupFile -Force
    Write-Host "Existing settings backed up to: $backupFile" -ForegroundColor Yellow
}

Copy-Item "$scriptDir\settings.json" $settingsFile -Force
Write-Host "Islands Dark settings applied to: $settingsFile" -ForegroundColor Green

Write-Host ""
Write-Host "Step 5: Finalization..."
$firstRunFile = Join-Path $scriptDir ".islands_dark_first_run_antigravity"
if (-not (Test-Path $firstRunFile)) {
    New-Item -ItemType File -Path $firstRunFile | Out-Null
    Write-Host "Important:" -ForegroundColor Yellow
    Write-Host "   - Install IBM Plex Mono and FiraCode Nerd Font Mono separately"
    Write-Host "   - A 'corrupt installation' warning may appear after CSS injection"
    Write-Host "   - Dismiss it with 'Don't Show Again'"
}

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "   1. Restart Antigravity"
Write-Host "   2. Select color theme: Islands Dark"
Write-Host "   3. If styles do not apply, run 'Custom UI Style: Reload'"
