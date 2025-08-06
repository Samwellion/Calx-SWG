#!/bin/bash
# Clean extended attributes from macOS build products to prevent CodeSign errors

echo "Cleaning extended attributes from build products..."

# Clean the build directory
if [ -d "build/macos/Build/Products" ]; then
    find build/macos/Build/Products -name "*.app" -exec xattr -cr {} \;
    echo "Cleaned extended attributes from .app bundles"
    
    # Try to manually sign the app
    APP_PATH=$(find build/macos/Build/Products -name "*.app" | head -1)
    if [ -n "$APP_PATH" ]; then
        echo "Re-signing app at: $APP_PATH"
        codesign --force --deep --sign - "$APP_PATH"
        echo "App re-signed successfully"
    fi
fi

echo "Build cleanup complete"
