#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="FnLangSwitch"
DMG_NAME="FnLangSwitch-Installer"
VERSION="1.0"

BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_DIR="$BUILD_DIR/dmg"
DMG_FILE="$BUILD_DIR/$DMG_NAME-$VERSION.dmg"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Приложение не собрано. Сначала выполните: ./scripts/build.sh"
    exit 1
fi

echo "📀 Создание DMG образа..."

rm -rf "$DMG_DIR"
rm -f "$DMG_FILE"
mkdir -p "$DMG_DIR"

cp -R "$APP_BUNDLE" "$DMG_DIR/"

ln -s /Applications "$DMG_DIR/Applications"

cat > "$DMG_DIR/УСТАНОВКА.txt" << 'EOF'
# Fn Lang Switch — Установка

1. Перетащите FnLangSwitch.app в папку Applications
2. Запустите приложение из Applications
3. Добавьте приложение в Accessibility:
   System Settings → Privacy & Security → Accessibility
   Нажмите '+' и выберите FnLangSwitch.app

Без разрешения Accessibility приложение не сможет 
отслеживать нажатия клавиши Fn.

## Использование

| Действие | По умолчанию |
|----------|--------------|
| Fn × 2   | Русский      |
| Fn × 3   | English      |
| Fn × 4   | —            |

Настройки: кликните на иконку 🌐 в менюбаре → Настройки...
EOF

echo "📦 Упаковка DMG..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_FILE"

rm -rf "$DMG_DIR"

echo ""
echo "✅ DMG создан: $DMG_FILE"
echo ""
echo "📦 Размер: $(du -h "$DMG_FILE" | cut -f1)"

