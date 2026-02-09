#!/bin/bash

# XRPL Result Codes - Enhanced Installer
# Handles macOS Gatekeeper security warnings automatically

echo "🚀 XRPL Result Codes Installer"
echo "=============================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only."
    exit 1
fi

# Check if app bundle exists
if [[ ! -d "XRPLResultCodes.app" ]]; then
    echo "❌ XRPLResultCodes.app not found in current directory."
    echo "   Make sure you're running this script from the extracted release folder."
    exit 1
fi

echo "📱 Found XRPLResultCodes.app"

# Remove quarantine attribute to bypass Gatekeeper
echo "🔓 Removing macOS quarantine flag..."
xattr -dr com.apple.quarantine XRPLResultCodes.app 2>/dev/null || true

# Check if Applications directory is writable
if [[ -w "/Applications" ]]; then
    INSTALL_DIR="/Applications"
    echo "📁 Installing to: $INSTALL_DIR"
else
    INSTALL_DIR="$HOME/Applications"
    echo "📁 Installing to user Applications: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Remove existing installation
if [[ -d "$INSTALL_DIR/XRPLResultCodes.app" ]]; then
    echo "🗑️  Removing existing installation..."
    rm -rf "$INSTALL_DIR/XRPLResultCodes.app"
fi

# Copy app to Applications
echo "📦 Copying application..."
cp -R XRPLResultCodes.app "$INSTALL_DIR/"

# Verify installation
if [[ -d "$INSTALL_DIR/XRPLResultCodes.app" ]]; then
    echo "✅ Installation successful!"
    echo ""
    echo "🎉 XRPL Result Codes has been installed to:"
    echo "   $INSTALL_DIR/XRPLResultCodes.app"
    echo ""
    echo "🚀 To launch the app:"
    echo "   1. Look for 'XRPLResultCodes' in Launchpad or Applications"
    echo "   2. Or run: open '$INSTALL_DIR/XRPLResultCodes.app'"
    echo "   3. The app will appear in your menu bar"
    echo ""
    echo "💡 Note: The app monitors both XRPL and Xahau networks"
    echo "   Click the menu bar icon to view transaction result codes"
    echo ""
    
    # Ask if user wants to launch now
    read -p "🚀 Would you like to launch the app now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎯 Launching XRPL Result Codes..."
        open "$INSTALL_DIR/XRPLResultCodes.app"
        echo "✨ Check your menu bar for the app icon!"
    fi
else
    echo "❌ Installation failed"
    exit 1
fi