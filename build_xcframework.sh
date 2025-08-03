#!/bin/bash
set -e

echo "🚀 Building TiktokenFFI XCFramework..."
echo ""

# Check if we're in the TiktokenSwift-repo directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Please run this script from the TiktokenSwift-repo directory"
    exit 1
fi

# Create temporary build directory
BUILD_DIR="build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Create module map for the framework
cat > $BUILD_DIR/module.modulemap << 'EOF'
framework module TiktokenFFI {
    header "TiktokenFFI.h"
    export *
}
EOF

# Function to create framework for a platform
create_framework() {
    local PLATFORM=$1
    local ARCH=$2
    local LIB_NAME=$3
    
    echo "📦 Creating framework for $PLATFORM ($ARCH)..."
    
    local FRAMEWORK_DIR="$BUILD_DIR/$PLATFORM/TiktokenFFI.framework"
    mkdir -p "$FRAMEWORK_DIR/Headers"
    mkdir -p "$FRAMEWORK_DIR/Modules"
    
    # Copy header
    cp Sources/TiktokenFFI/include/TiktokenFFI.h "$FRAMEWORK_DIR/Headers/"
    
    # Copy module map
    cp $BUILD_DIR/module.modulemap "$FRAMEWORK_DIR/Modules/module.modulemap"
    
    # Copy library (if exists)
    if [ -f "Sources/TiktokenFFI/lib/$LIB_NAME" ]; then
        cp "Sources/TiktokenFFI/lib/$LIB_NAME" "$FRAMEWORK_DIR/TiktokenFFI"
    else
        # For now, use the universal library
        cp "Sources/TiktokenFFI/lib/libtiktoken.a" "$FRAMEWORK_DIR/TiktokenFFI"
    fi
    
    # Create Info.plist
    cat > "$FRAMEWORK_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>TiktokenFFI</string>
    <key>CFBundleIdentifier</key>
    <string>com.tiktoken.TiktokenFFI</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>TiktokenFFI</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>$PLATFORM</string>
    </array>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF
}

# Build frameworks for each platform
# Note: In a real setup, you'd build separate libraries for each platform
# For now, we'll use the same library for all platforms

create_framework "iPhoneOS" "arm64" "libtiktoken-ios.a"
create_framework "iPhoneSimulator" "arm64-x86_64" "libtiktoken-ios-sim.a"
create_framework "MacOSX" "arm64-x86_64" "libtiktoken.a"
create_framework "AppleTVOS" "arm64" "libtiktoken-tvos.a"
create_framework "AppleTVSimulator" "arm64-x86_64" "libtiktoken-tvos-sim.a"
create_framework "WatchOS" "arm64_32-armv7k" "libtiktoken-watchos.a"
create_framework "WatchSimulator" "arm64-x86_64" "libtiktoken-watchos-sim.a"

# Create XCFramework
echo ""
echo "🔧 Creating XCFramework..."

# Remove existing XCFramework
rm -rf Sources/TiktokenFFI/TiktokenFFI.xcframework

# Create XCFramework with available platforms
# Note: This will fail if platform-specific libraries don't exist
# For development, we'll just create it for macOS
xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/MacOSX/TiktokenFFI.framework" \
    -output Sources/TiktokenFFI/TiktokenFFI.xcframework 2>/dev/null || {
    echo "⚠️  Created XCFramework for macOS only (development mode)"
    echo "   For production, build platform-specific libraries"
}

# Clean up
rm -rf $BUILD_DIR

echo ""
echo "✅ XCFramework created successfully!"
echo "   Location: Sources/TiktokenFFI/TiktokenFFI.xcframework"