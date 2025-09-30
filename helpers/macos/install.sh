#!/bin/bash
# Sixarata macOS Installation Helper
# This script removes the quarantine attribute from the downloaded app

set -e

echo "=========================================="
echo "  Sixarata macOS Installation Helper"
echo "=========================================="
echo ""

# Find the .app bundle
APP_PATH=""
if [ -d "Sixarata.app" ]; then
    APP_PATH="Sixarata.app"
elif [ -d "*/Sixarata.app" ]; then
    APP_PATH="$(find . -name "Sixarata.app" -type d -maxdepth 2 -print -quit)"
fi

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find Sixarata.app in the current directory."
    echo ""
    echo "Please run this script from the directory containing Sixarata.app"
    exit 1
fi

echo "Found: $APP_PATH"
echo ""
echo "Removing macOS quarantine attribute..."

# Remove quarantine attribute
xattr -cr "$APP_PATH"

echo "✓ Done!"
echo ""
echo "Sixarata.app is now ready to run."
echo "You can launch it by double-clicking or running:"
echo "  open \"$APP_PATH\""
echo ""
