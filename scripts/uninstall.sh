#!/bin/bash
set -e

APP_NAME="FnLangSwitch"
BUNDLE_ID="com.voicelangswitch.app"
INSTALL_DIR="/Applications"
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"
PREFS_FILE="$HOME/Library/Preferences/$BUNDLE_ID.plist"

echo "🗑️  Удаление $APP_NAME..."

echo "⏹️  Остановка приложения..."
pkill -x "$APP_NAME" 2>/dev/null || true

if [ -f "$LAUNCH_AGENT_PLIST" ]; then
    echo "🔧 Удаление автозапуска..."
    launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
    rm -f "$LAUNCH_AGENT_PLIST"
fi

if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    echo "📁 Удаление приложения..."
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
fi

echo ""
echo "Удалить настройки приложения? (y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    rm -f "$PREFS_FILE"
    defaults delete "$BUNDLE_ID" 2>/dev/null || true
    echo "🗑️  Настройки удалены"
fi

echo ""
echo "✅ Удаление завершено!"
echo ""
echo "📋 Не забудьте удалить приложение из Accessibility:"
echo "   System Settings → Privacy & Security → Accessibility"

