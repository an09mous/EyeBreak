#!/bin/bash

# Build script for Eyebreak

set -e

# Parse arguments
BUILD_DMG=false
BUILD_RELEASE=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dmg) BUILD_DMG=true ;;
        --release) BUILD_RELEASE=true ;;
        -h|--help)
            echo "Usage: ./build.sh [options]"
            echo ""
            echo "Options:"
            echo "  --release    Build in release mode (optimized)"
            echo "  --dmg        Create a DMG file for distribution"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Determine build configuration
if [ "$BUILD_RELEASE" = true ]; then
    BUILD_CONFIG="release"
    SWIFT_BUILD_FLAGS="-c release"
    echo "Building Eyebreak (Release)..."
else
    BUILD_CONFIG="debug"
    SWIFT_BUILD_FLAGS=""
    echo "Building Eyebreak (Debug)..."
fi

# Build with Swift Package Manager
swift build $SWIFT_BUILD_FLAGS

# Create app bundle structure
mkdir -p Eyebreak.app/Contents/MacOS
mkdir -p Eyebreak.app/Contents/Resources

# Copy executable
cp .build/$BUILD_CONFIG/Eyebreak Eyebreak.app/Contents/MacOS/
chmod +x Eyebreak.app/Contents/MacOS/Eyebreak

# Copy resources
cp Sources/Eyebreak/Resources/quotes.json Eyebreak.app/Contents/Resources/
cp Sources/Eyebreak/Resources/config.json Eyebreak.app/Contents/Resources/
cp -r .build/$BUILD_CONFIG/Eyebreak_Eyebreak.bundle Eyebreak.app/Contents/Resources/

# Create Info.plist
cat > Eyebreak.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Eyebreak</string>
    <key>CFBundleIdentifier</key>
    <string>com.eyebreak.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Eyebreak</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024. All rights reserved.</string>
</dict>
</plist>
EOF

echo "App bundle created: Eyebreak.app"

# Create DMG if requested
if [ "$BUILD_DMG" = true ]; then
    echo "Creating DMG..."

    DMG_NAME="Eyebreak-1.0.dmg"
    DMG_TEMP="dmg_temp"

    # Clean up any previous DMG artifacts
    rm -rf "$DMG_TEMP"
    rm -f "$DMG_NAME"

    # Create temporary directory for DMG contents
    mkdir -p "$DMG_TEMP"

    # Copy app to temp directory
    cp -r Eyebreak.app "$DMG_TEMP/"

    # Create symbolic link to Applications folder
    ln -s /Applications "$DMG_TEMP/Applications"

    # Create the DMG
    hdiutil create -volname "Eyebreak" \
        -srcfolder "$DMG_TEMP" \
        -ov -format UDZO \
        "$DMG_NAME"

    # Clean up
    rm -rf "$DMG_TEMP"

    echo "DMG created: $DMG_NAME"
fi

echo ""
echo "Build complete!"
echo "  Run app:    open Eyebreak.app"
if [ "$BUILD_DMG" = true ]; then
    echo "  Distribute: $DMG_NAME"
fi
