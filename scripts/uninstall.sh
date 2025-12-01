#!/bin/bash
set -e

APP_NAME="MacLangTools"
BUNDLE_ID="com.maclangtools.app"
INSTALL_DIR="/Applications"
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"
PREFS_FILE="$HOME/Library/Preferences/$BUNDLE_ID.plist"

echo "🗑️  Uninstalling $APP_NAME..."

echo "⏹️  Stopping app..."
pkill -x "$APP_NAME" 2>/dev/null || true

if [ -f "$LAUNCH_AGENT_PLIST" ]; then
    echo "🔧 Removing auto-start..."
    launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
    rm -f "$LAUNCH_AGENT_PLIST"
fi

if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    echo "📁 Removing app..."
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
fi

echo ""
echo "Remove app settings? (y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    rm -f "$PREFS_FILE"
    defaults delete "$BUNDLE_ID" 2>/dev/null || true
    echo "🗑️  Settings removed"
fi

echo ""
echo "✅ Uninstall complete!"
echo ""
echo "📋 Don't forget to remove the app from Accessibility:"
echo "   System Settings → Privacy & Security → Accessibility"

