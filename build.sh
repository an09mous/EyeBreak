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

# Generate app icon from source PNG if needed
ICON_SOURCE="Sources/Eyebreak/Resources/AppIcon.png"
ICON_ICNS="Sources/Eyebreak/Resources/AppIcon.icns"
if [ "$ICON_SOURCE" -nt "$ICON_ICNS" ] || [ ! -f "$ICON_ICNS" ]; then
    echo "Generating app icon..."
    ICONSET_DIR="AppIcon.iconset"
    mkdir -p "$ICONSET_DIR"

    # Generate all required sizes using sips
    for size in 16 32 64 128 256 512 1024; do
        sips -z $size $size "$ICON_SOURCE" --out "$ICONSET_DIR/icon_${size}x${size}.png" > /dev/null 2>&1
    done

    # Rename to match macOS iconset naming convention
    mv "$ICONSET_DIR/icon_16x16.png" "$ICONSET_DIR/icon_16x16.png"
    cp "$ICONSET_DIR/icon_32x32.png" "$ICONSET_DIR/icon_16x16@2x.png"
    mv "$ICONSET_DIR/icon_64x64.png" "$ICONSET_DIR/icon_32x32@2x.png"
    cp "$ICONSET_DIR/icon_256x256.png" "$ICONSET_DIR/icon_128x128@2x.png"
    cp "$ICONSET_DIR/icon_512x512.png" "$ICONSET_DIR/icon_256x256@2x.png"
    mv "$ICONSET_DIR/icon_1024x1024.png" "$ICONSET_DIR/icon_512x512@2x.png"

    # Convert to icns
    iconutil -c icns "$ICONSET_DIR" -o "$ICON_ICNS"
    rm -rf "$ICONSET_DIR"
    echo "App icon generated."
fi

# Create app bundle structure
mkdir -p Eyebreak.app/Contents/MacOS
mkdir -p Eyebreak.app/Contents/Resources

# Copy executable
cp .build/$BUILD_CONFIG/Eyebreak Eyebreak.app/Contents/MacOS/
chmod +x Eyebreak.app/Contents/MacOS/Eyebreak

# Copy resources
cp Sources/Eyebreak/Resources/quotes.json Eyebreak.app/Contents/Resources/
cp Sources/Eyebreak/Resources/config.json Eyebreak.app/Contents/Resources/
cp Sources/Eyebreak/Resources/AppIcon.icns Eyebreak.app/Contents/Resources/
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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "App bundle created: Eyebreak.app"

# Create DMG if requested
if [ "$BUILD_DMG" = true ]; then
    echo "Creating DMG..."

    BUILD_DIR="build"
    DMG_NAME="Eyebreak-1.0.dmg"
    DMG_TEMP="dmg_temp"

    # Create build directory
    mkdir -p "$BUILD_DIR"

    # Clean up any previous DMG artifacts
    rm -rf "$DMG_TEMP"
    rm -f "$BUILD_DIR/$DMG_NAME"

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
        "$BUILD_DIR/$DMG_NAME"

    # Clean up
    rm -rf "$DMG_TEMP"

    echo "DMG created: $BUILD_DIR/$DMG_NAME"
fi

echo ""
echo "Build complete!"
echo "  Run app:    open Eyebreak.app"
if [ "$BUILD_DMG" = true ]; then
    echo "  Distribute: $BUILD_DIR/$DMG_NAME"
fi
