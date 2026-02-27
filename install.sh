#!/bin/bash

set -euo pipefail

echo "Islands Dark Theme Installer for Antigravity (macOS/Linux)"
echo "==========================================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

find_antigravity_cli() {
    if command -v antigravity >/dev/null 2>&1; then
        command -v antigravity
        return 0
    fi

    local candidates=(
        "$HOME/.antigravity/antigravity/bin/antigravity"
        "/Applications/Antigravity.app/Contents/Resources/app/bin/antigravity"
        "/opt/antigravity/bin/antigravity"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

if ! ANTIGRAVITY_CLI="$(find_antigravity_cli)"; then
    echo -e "${RED}Error: Antigravity CLI not found.${NC}"
    echo "Install Antigravity and ensure 'antigravity' is in PATH."
    echo "On macOS, Antigravity usually provides:"
    echo "  ~/.antigravity/antigravity/bin/antigravity"
    exit 1
fi

echo -e "${GREEN}Antigravity CLI found:${NC} $ANTIGRAVITY_CLI"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "Step 1: Installing Islands Dark theme extension..."

EXT_ROOT="$HOME/.antigravity/extensions"
EXT_DIR="$EXT_ROOT/bwya77.islands-dark-1.0.0"
rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"
cp "$SCRIPT_DIR/package.json" "$EXT_DIR/"
cp -r "$SCRIPT_DIR/themes" "$EXT_DIR/"

if [ -d "$EXT_DIR/themes" ]; then
    echo -e "${GREEN}Theme extension installed to:${NC} $EXT_DIR"
else
    echo -e "${RED}Failed to install theme extension.${NC}"
    exit 1
fi

EXT_JSON="$EXT_ROOT/extensions.json"
if [ -f "$EXT_JSON" ]; then
    rm -f "$EXT_JSON"
    echo -e "${GREEN}Cleared extensions.json (Antigravity will rebuild it).${NC}"
fi

echo ""
echo "Step 2: Installing Custom UI Style extension..."
if "$ANTIGRAVITY_CLI" --install-extension subframe7536.custom-ui-style --force; then
    echo -e "${GREEN}Custom UI Style extension installed.${NC}"
else
    echo -e "${YELLOW}Could not install Custom UI Style automatically.${NC}"
    echo "Install it manually from Antigravity Extensions."
fi

echo ""
echo "Step 3: Installing Bear Sans UI fonts..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
    cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null || true
    echo -e "${GREEN}Fonts installed to:${NC} $FONT_DIR"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null || true
    fc-cache -f 2>/dev/null || true
    echo -e "${GREEN}Fonts installed to:${NC} $FONT_DIR"
else
    echo -e "${YELLOW}Could not detect OS type for automatic font install.${NC}"
fi

echo ""
echo "Step 4: Applying Antigravity settings..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    SETTINGS_DIR="$HOME/Library/Application Support/Antigravity/User"
else
    SETTINGS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Antigravity/User"
fi

mkdir -p "$SETTINGS_DIR"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
BACKUP_FILE="$SETTINGS_FILE.pre-islands-dark"

if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}Backed up existing settings to:${NC} $BACKUP_FILE"
fi

cp "$SCRIPT_DIR/settings.json" "$SETTINGS_FILE"
echo -e "${GREEN}Islands Dark settings applied to:${NC} $SETTINGS_FILE"

echo ""
echo "Step 5: Finalization..."
FIRST_RUN_FILE="$SCRIPT_DIR/.islands_dark_first_run_antigravity"
if [ ! -f "$FIRST_RUN_FILE" ]; then
    touch "$FIRST_RUN_FILE"
    echo -e "${YELLOW}Important:${NC}"
    echo "  - Install IBM Plex Mono and FiraCode Nerd Font Mono separately."
    echo "  - A 'corrupt installation' warning may appear after Custom UI Style."
    echo "    Dismiss it with 'Don't Show Again'."
fi

echo ""
echo -e "${GREEN}Setup complete.${NC}"
echo "Next steps:"
echo "  1. Restart Antigravity."
echo "  2. Select color theme: Islands Dark."
echo "  3. If styles do not apply, run 'Custom UI Style: Reload'."
