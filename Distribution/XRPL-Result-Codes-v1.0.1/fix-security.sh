#!/bin/bash

# XRPL Result Codes - Universal Security Fix
# This script handles all macOS Gatekeeper security warnings

echo "🛡️  XRPL Result Codes - Security Fix Tool"
echo "========================================"
echo ""
echo "This tool fixes the macOS 'app is damaged' security warning."
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This tool is for macOS only."
    exit 1
fi

# Find the app bundle in current directory or subdirectories
APP_PATH=""
if [[ -d "XRPLResultCodes.app" ]]; then
    APP_PATH="XRPLResultCodes.app"
elif [[ -d "XRPL-Result-Codes-v*/XRPLResultCodes.app" ]]; then
    APP_PATH=$(find . -name "XRPLResultCodes.app" -type d | head -1)
else
    echo "❌ XRPLResultCodes.app not found."
    echo ""
    echo "📁 Make sure you have:"
    echo "   1. Downloaded the release zip file"
    echo "   2. Extracted/unzipped it completely"
    echo "   3. Are running this script from the extracted folder"
    echo ""
    echo "🔍 Looking for app in current directory..."
    find . -name "*.app" -type d 2>/dev/null || echo "   No .app files found"
    exit 1
fi

echo "📱 Found app: $APP_PATH"
echo ""

# Remove quarantine attributes from the entire app bundle
echo "🔓 Removing macOS security restrictions..."
xattr -rd com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# Also remove from all Contents
find "$APP_PATH" -type f -exec xattr -d com.apple.quarantine {} \; 2>/dev/null || true

echo "✅ Security restrictions removed!"
echo ""

# Test if app can launch
echo "🧪 Testing app launch..."
if open -g "$APP_PATH"; then
    echo "✅ App launched successfully!"
    echo ""
    echo "🎉 The app should now appear in your menu bar."
    echo "   Look for a small icon in the top-right corner of your screen."
    echo ""
    
    # Ask about installation
    read -p "📦 Would you like to install the app to Applications folder? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Determine install location
        if [[ -w "/Applications" ]]; then
            INSTALL_DIR="/Applications"
        else
            INSTALL_DIR="$HOME/Applications"
            mkdir -p "$INSTALL_DIR"
        fi
        
        # Remove existing installation
        if [[ -d "$INSTALL_DIR/XRPLResultCodes.app" ]]; then
            echo "🗑️  Removing existing installation..."
            rm -rf "$INSTALL_DIR/XRPLResultCodes.app"
        fi
        
        # Copy to Applications
        echo "📦 Installing to $INSTALL_DIR..."
        cp -R "$APP_PATH" "$INSTALL_DIR/"
        
        if [[ -d "$INSTALL_DIR/XRPLResultCodes.app" ]]; then
            echo "✅ Installation complete!"
            echo "   📱 App installed to: $INSTALL_DIR/XRPLResultCodes.app"
        else
            echo "❌ Installation failed"
        fi
    else
        echo "📝 App is ready to run from current location."
        echo "   You can run: open '$APP_PATH'"
    fi
else
    echo "⚠️  App test launch failed, but restrictions have been removed."
    echo ""
    echo "🔧 Alternative solutions:"
    echo "   1. Right-click on '$APP_PATH' → Open"
    echo "   2. Try: open '$APP_PATH'"
    echo "   3. Go to System Settings → Privacy & Security"
    echo "      and look for 'Open Anyway' button"
fi

echo ""
echo "🎯 App Features:"
echo "   • Monitor XRPL and Xahau transaction result codes"
echo "   • Automatic network switching and data caching"
echo "   • Real-time updates every 5 minutes"
echo "   • Native macOS menu bar integration"
echo ""
echo "📞 Need help? Check the README.md file or repository documentation."