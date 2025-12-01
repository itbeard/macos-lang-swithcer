# MacLangTools ⌨️

A macOS app that switches input language by multiple Option key presses.

## How it works

| Action | Default |
|--------|---------|
| Option × 2 (double tap) | Russian |
| Option × 3 (triple tap) | English |
| Option × 4 (quadruple tap) | — |

All bindings are configurable through the UI!

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools (for building)

## Quick Install

```bash
./scripts/build.sh    # Build
./scripts/install.sh  # Install + auto-start
```

## Create DMG for distribution

```bash
./scripts/build.sh
./scripts/create-dmg.sh
```

DMG will be created at `.build/MacLangTools-Installer-1.0.dmg`

## Uninstall

```bash
./scripts/uninstall.sh
```

## Manual Build

```bash
swift build -c release
.build/release/VoiceLangSwitch
```

## Settings

1. Click the 🌐 icon in the menu bar
2. Select "Settings..."
3. Assign languages to double/triple/quadruple tap
4. Adjust tap interval (default 300ms)

## Permissions

**Required:** Add the app to:
- System Settings → Privacy & Security → Accessibility

Without this permission, the app cannot track Option key presses.

## Troubleshooting

**Option key not working:**
- Make sure the app is added to Accessibility
- Try disabling conflicting shortcuts in System Settings → Keyboard

**Language not switching:**
- Check that required languages are added in System Settings → Keyboard → Input Sources

## Technical Details

- **CGEventTap** — key press interception
- **Carbon API (TISInputSource)** — keyboard layout switching
- **SwiftUI** — settings UI
- **UserDefaults** — settings storage

## Project Structure

```
Sources/
├── VoiceLangSwitchApp.swift  # Main application
├── HotkeyManager.swift       # Multi-tap Option
├── InputSourceManager.swift  # Language switching
├── Settings.swift            # Settings model
└── SettingsView.swift        # Settings UI
```
