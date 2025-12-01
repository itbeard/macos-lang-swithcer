#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="MacLangTools"
DMG_NAME="MacLangTools-Installer"
VERSION="1.0"

BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_DIR="$BUILD_DIR/dmg"
DMG_FILE="$BUILD_DIR/$DMG_NAME-$VERSION.dmg"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App not built. First run: ./scripts/build.sh"
    exit 1
fi

echo "📀 Creating DMG image..."

rm -rf "$DMG_DIR"
rm -f "$DMG_FILE"
mkdir -p "$DMG_DIR"

cp -R "$APP_BUNDLE" "$DMG_DIR/"

ln -s /Applications "$DMG_DIR/Applications"

cat > "$DMG_DIR/README.txt" << 'EOF'
# MacLangTools — Installation

1. Drag MacLangTools.app to the Applications folder
2. Launch the app from Applications
3. Add the app to Accessibility:
   System Settings → Privacy & Security → Accessibility
   Click '+' and select MacLangTools.app

Without Accessibility permission, the app cannot
track Option key presses.

## Usage

| Action      | Default |
|-------------|---------|
| Option × 2  | Russian |
| Option × 3  | English |
| Option × 4  | —       |

Settings: click the 🌐 icon in the menu bar → Settings...
EOF

echo "📦 Packaging DMG..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_FILE"

rm -rf "$DMG_DIR"

echo ""
echo "✅ DMG created: $DMG_FILE"
echo ""
echo "📦 Size: $(du -h "$DMG_FILE" | cut -f1)"

