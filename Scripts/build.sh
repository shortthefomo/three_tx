#!/bin/bash

# XRPL Result Codes - Build Script
# Compiles and packages the macOS menu bar application

set -e  # Exit on any error

# Configuration
APP_NAME="XRPL Result Codes"
APP_BUNDLE_NAME="XRPLResultCodes.app"
BUNDLE_ID="com.xrpl.resultcodes"
VERSION="1.0"
SWIFT_SOURCE="Source/XRPLMenuBarApp.swift"

# Directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/Build"
SOURCE_DIR="$PROJECT_ROOT/Source"
DIST_DIR="$PROJECT_ROOT/Distribution"

echo "🔨 Building $APP_NAME"
echo "=================================="
echo "Project Root: $PROJECT_ROOT"
echo "Build Dir: $BUILD_DIR"
echo "Source: $SWIFT_SOURCE"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf "$BUILD_DIR/$APP_BUNDLE_NAME"
rm -f "$BUILD_DIR/XRPLResultCodes"

# Create build directory structure
echo "📁 Creating app bundle structure..."
mkdir -p "$BUILD_DIR/$APP_BUNDLE_NAME/Contents/MacOS"
mkdir -p "$BUILD_DIR/$APP_BUNDLE_NAME/Contents/Resources"

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "$BUILD_DIR/$APP_BUNDLE_NAME/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>XRPLResultCodes</string>
	<key>CFBundleIdentifier</key>
	<string>com.xrpl.resultcodes</string>
	<key>CFBundleName</key>
	<string>XRPL Result Codes</string>
	<key>CFBundleDisplayName</key>
	<string>XRPL Result Codes</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleSignature</key>
	<string>XRPL</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSSupportsAutomaticGraphicsSwitching</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>© 2026 XRPL Result Codes</string>
</dict>
</plist>
EOF

# Compile Swift source
echo "⚡ Compiling Swift source..."
cd "$PROJECT_ROOT"
swiftc -parse-as-library \
       -o "$BUILD_DIR/$APP_BUNDLE_NAME/Contents/MacOS/XRPLResultCodes" \
       "$SWIFT_SOURCE" \
       -framework SwiftUI \
       -framework AppKit \
       -framework Foundation

# Set executable permissions
chmod +x "$BUILD_DIR/$APP_BUNDLE_NAME/Contents/MacOS/XRPLResultCodes"

# Verify build
if [[ -f "$BUILD_DIR/$APP_BUNDLE_NAME/Contents/MacOS/XRPLResultCodes" ]]; then
    echo "✅ Build completed successfully!"
    echo ""
    echo "📱 App bundle: $BUILD_DIR/$APP_BUNDLE_NAME"
    echo "💾 Size: $(du -h "$BUILD_DIR/$APP_BUNDLE_NAME" | tail -1 | cut -f1)"
    echo ""
    echo "🚀 To test: open '$BUILD_DIR/$APP_BUNDLE_NAME'"
    echo "📦 To distribute: run 'Scripts/create_distribution.sh'"
else
    echo "❌ Build failed!"
    exit 1
fi