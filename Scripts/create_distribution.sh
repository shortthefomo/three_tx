#!/bin/bash

# XRPL Result Codes - Create Distribution Package
# This script creates a distributable package for the XRPL Result Codes app

DIST_NAME="XRPL-Result-Codes-v1.0"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/Build"
DIST_OUTPUT_DIR="$PROJECT_ROOT/Distribution"

echo "📦 Creating distribution package: $DIST_NAME"
echo "=============================================="
echo "Project Root: $PROJECT_ROOT"
echo "Build Dir: $BUILD_DIR"
echo "Distribution Dir: $DIST_OUTPUT_DIR"
echo ""

# Check if app bundle exists
if [[ ! -d "$BUILD_DIR/XRPLResultCodes.app" ]]; then
    echo "❌ Error: XRPLResultCodes.app not found in Build directory"
    echo "Please run 'Scripts/build.sh' first to build the application"
    exit 1
fi

DIST_DIR="$DIST_OUTPUT_DIR/$DIST_NAME"

# Clean up any existing distribution
if [[ -d "$DIST_DIR" ]]; then
    echo "🗑️  Removing existing distribution directory..."
    rm -rf "$DIST_DIR"
fi

if [[ -f "$DIST_OUTPUT_DIR/$DIST_NAME.zip" ]]; then
    echo "🗑️  Removing existing zip file..."
    rm -f "$DIST_OUTPUT_DIR/$DIST_NAME.zip"
fi

# Create distribution directory
echo "📁 Creating distribution directory..."
mkdir -p "$DIST_DIR"

# Copy files to distribution
echo "📋 Copying application bundle..."
cp -R "$BUILD_DIR/XRPLResultCodes.app" "$DIST_DIR/"

echo "📋 Copying installer script..."
cp "$PROJECT_ROOT/Scripts/install.sh" "$DIST_DIR/"

echo "📋 Copying documentation..."
cp "$PROJECT_ROOT/README_Distribution.md" "$DIST_DIR/README.md"

# Create a simple launcher for those who prefer not to use installer
echo "📋 Creating alternative launcher..."
cat > "$DIST_DIR/launch.sh" << 'EOF'
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
EOF

chmod +x "$DIST_DIR/launch.sh"

# Create version info file
cat > "$DIST_DIR/VERSION" << EOF
XRPL Result Codes Menu Bar App
Version: 1.0
Build Date: $(date)
Platform: macOS 14.0+
Type: Native Swift Application
EOF

# Set proper permissions
echo "🔐 Setting file permissions..."
chmod +x "$DIST_DIR/install.sh"
chmod +x "$DIST_DIR/XRPLResultCodes.app/Contents/MacOS/XRPLResultCodes"

# Create zip archive
echo "🗜️  Creating zip archive..."
cd "$DIST_OUTPUT_DIR"
zip -r "$DIST_NAME.zip" "$DIST_NAME" > /dev/null
cd "$PROJECT_ROOT"

# Display results
echo ""
echo "✅ Distribution package created successfully!"
echo ""
echo "📁 Distribution folder: $DIST_DIR/"
echo "🗜️  Zip archive: $DIST_OUTPUT_DIR/$DIST_NAME.zip"
echo ""
echo "📋 Package contents:"
echo "   • XRPLResultCodes.app - Main application"
echo "   • install.sh - Automatic installer"
echo "   • launch.sh - Direct launcher (no install)"
echo "   • README.md - User documentation"
echo "   • VERSION - Version information"
echo ""
echo "🚀 Ready to share!"
echo ""
echo "💡 Users can either:"
echo "   1. Run './install.sh' to install to Applications"
echo "   2. Run './launch.sh' to run directly from folder"
echo "   3. Manually drag XRPLResultCodes.app to Applications"

# Show file sizes
echo ""
echo "📊 Package size:"
du -h "$DIST_OUTPUT_DIR/$DIST_NAME.zip"
ls -la "$DIST_DIR"