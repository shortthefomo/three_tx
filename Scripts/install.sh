#!/bin/bash

# XRPL Result Codes Installer Script
# This script installs the XRPL Result Codes menu bar application

APP_NAME="XRPL Result Codes"
APP_BUNDLE="XRPLResultCodes.app"
INSTALL_DIR="/Applications"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Installing $APP_NAME..."
echo "=================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ Please do not run this installer as root/sudo"
   exit 1
fi

# Check if the app bundle exists
if [[ ! -d "$SCRIPT_DIR/$APP_BUNDLE" ]]; then
    echo "❌ Error: $APP_BUNDLE not found in the same directory as this installer"
    echo "Please ensure both the installer script and $APP_BUNDLE are in the same folder"
    exit 1
fi

# Check if Applications directory is writable
if [[ ! -w "$INSTALL_DIR" ]]; then
    echo "📝 Administrator privileges required to install to $INSTALL_DIR"
    echo "You may be prompted for your password..."
fi

# Remove existing installation if it exists
if [[ -d "$INSTALL_DIR/$APP_BUNDLE" ]]; then
    echo "🗑️  Removing existing installation..."
    if [[ -w "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR/$APP_BUNDLE"
    else
        sudo rm -rf "$INSTALL_DIR/$APP_BUNDLE"
    fi
fi

# Copy the application to Applications folder
echo "📦 Copying $APP_NAME to Applications..."
if [[ -w "$INSTALL_DIR" ]]; then
    cp -R "$SCRIPT_DIR/$APP_BUNDLE" "$INSTALL_DIR/"
else
    sudo cp -R "$SCRIPT_DIR/$APP_BUNDLE" "$INSTALL_DIR/"
fi

# Verify installation
if [[ -d "$INSTALL_DIR/$APP_BUNDLE" ]]; then
    echo "✅ $APP_NAME installed successfully!"
    echo ""
    echo "📱 To use the application:"
    echo "   1. Open Applications folder"
    echo "   2. Double-click '$APP_NAME'"
    echo "   3. Look for the chart icon in your menu bar"
    echo "   4. Click the icon to view XRPL result codes"
    echo ""
    echo "🔄 The app will automatically refresh data every 5 minutes"
    echo "📊 No additional setup required - it connects directly to XRPL network"
    echo ""
    echo "❓ To uninstall: Delete '$APP_NAME' from Applications folder"
    
    # Ask if user wants to launch the app now
    read -p "🚀 Would you like to launch $APP_NAME now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎉 Launching $APP_NAME..."
        open "$INSTALL_DIR/$APP_BUNDLE"
    fi
else
    echo "❌ Installation failed!"
    echo "Please check permissions and try again"
    exit 1
fi

echo ""
echo "🎉 Installation complete!"