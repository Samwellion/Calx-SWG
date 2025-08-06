#!/bin/bash
# Build and run Flutter macOS app with CodeSign workaround

echo "Building Flutter macOS app with CodeSign workaround..."

# Clean build first
flutter clean

# Build the app (this will fail with CodeSign error)
echo "Building app (expect CodeSign error)..."
flutter build macos --debug

# Clean extended attributes and re-sign
echo "Cleaning extended attributes and re-signing..."
if [ -d "build/macos/Build/Products/Debug" ]; then
    find build/macos/Build/Products/Debug -name "*.app" -exec xattr -cr {} \;
    APP_PATH=$(find build/macos/Build/Products/Debug -name "*.app" | head -1)
    if [ -n "$APP_PATH" ]; then
        codesign --force --deep --sign - "$APP_PATH"
        echo "App successfully built and signed at: $APP_PATH"
        
        # Now try to run it
        echo "Launching app..."
        open "$APP_PATH"
    fi
fi
