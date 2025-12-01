#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="FnLangSwitch"
BUNDLE_ID="com.voicelangswitch.app"

BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
INSTALL_DIR="/Applications"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/$BUNDLE_ID.plist"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Приложение не собрано. Сначала выполните: ./scripts/build.sh"
    exit 1
fi

echo "🔧 Установка $APP_NAME..."

pkill -x "$APP_NAME" 2>/dev/null || true

echo "📁 Копирование в $INSTALL_DIR..."
rm -rf "$INSTALL_DIR/$APP_NAME.app"
cp -R "$APP_BUNDLE" "$INSTALL_DIR/"

echo "🚀 Настройка автозапуска..."
mkdir -p "$LAUNCH_AGENT_DIR"

cat > "$LAUNCH_AGENT_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$BUNDLE_ID</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/$APP_NAME.app/Contents/MacOS/$APP_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
launchctl load "$LAUNCH_AGENT_PLIST"

echo ""
echo "✅ Установка завершена!"
echo ""
echo "📋 Важно: Добавьте приложение в Accessibility:"
echo "   System Settings → Privacy & Security → Accessibility"
echo "   Нажмите '+' и добавьте: /Applications/$APP_NAME.app"
echo ""
echo "🚀 Запустить сейчас? (y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    open "$INSTALL_DIR/$APP_NAME.app"
    echo "✅ Приложение запущено!"
fi

