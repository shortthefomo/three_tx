#!/bin/bash

# Create DMG installer for XRPL Result Codes
DMG_NAME="XRPL-Result-Codes-v1.0"
VOLUME_NAME="XRPL Result Codes"
APP_NAME="XRPLResultCodes.app"

echo "💿 Creating DMG installer..."

# Create temporary directory for DMG contents
TEMP_DMG_DIR="/tmp/xrpl_dmg"
rm -rf "$TEMP_DMG_DIR"
mkdir -p "$TEMP_DMG_DIR"

# Copy app to temp directory
cp -R "$APP_NAME" "$TEMP_DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DMG_DIR/Applications"

# Create DMG
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DMG_DIR" -ov -format UDZO "$DMG_NAME.dmg"

# Clean up
rm -rf "$TEMP_DMG_DIR"

echo "✅ DMG created: $DMG_NAME.dmg"