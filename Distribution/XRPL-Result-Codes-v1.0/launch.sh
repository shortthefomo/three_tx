#!/bin/bash
# Simple launcher for XRPL Result Codes
# This launches the app directly without installing to Applications

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$SCRIPT_DIR/XRPLResultCodes.app/Contents/MacOS/XRPLResultCodes"

echo "🚀 Launching XRPL Result Codes..."

if [[ -f "$APP_PATH" ]]; then
    "$APP_PATH" &
    echo "✅ App launched! Look for the chart icon in your menu bar."
else
    echo "❌ Error: Application not found"
    exit 1
fi
