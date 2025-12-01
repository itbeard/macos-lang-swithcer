#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RESOURCES_DIR="$PROJECT_DIR/Resources"
ICONSET_DIR="$RESOURCES_DIR/AppIcon.iconset"

mkdir -p "$ICONSET_DIR"

# Create a simple icon using sips and a base PNG
# First, create a base icon using a compiled Swift program

cat > /tmp/create_icon.swift << 'SWIFT'
import Cocoa

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

func createIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let padding = CGFloat(size) * 0.08
    let innerRect = rect.insetBy(dx: padding, dy: padding)
    
    let gradient = NSGradient(colors: [
        NSColor(red: 0.25, green: 0.55, blue: 0.95, alpha: 1.0),
        NSColor(red: 0.55, green: 0.3, blue: 0.85, alpha: 1.0)
    ])!
    
    let path = NSBezierPath(roundedRect: innerRect, xRadius: CGFloat(size) * 0.22, yRadius: CGFloat(size) * 0.22)
    gradient.draw(in: path, angle: -45)
    
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
    shadow.shadowOffset = NSSize(width: 0, height: -CGFloat(size) * 0.02)
    shadow.shadowBlurRadius = CGFloat(size) * 0.05
    shadow.set()
    
    let fontSize = CGFloat(size) * 0.45
    let font = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    let text = "⌥"
    let textSize = text.size(withAttributes: attrs)
    let textPoint = NSPoint(
        x: (CGFloat(size) - textSize.width) / 2,
        y: (CGFloat(size) - textSize.height) / 2 - CGFloat(size) * 0.02
    )
    text.draw(at: textPoint, withAttributes: attrs)
    
    image.unlockFocus()
    return image
}

let outputDir = CommandLine.arguments[1]

for (size, filename) in sizes {
    let image = createIcon(size: size)
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        continue
    }
    let url = URL(fileURLWithPath: "\(outputDir)/\(filename)")
    try? pngData.write(to: url)
}

print("Done")
SWIFT

echo "🎨 Generating app icon..."

swiftc -o /tmp/create_icon /tmp/create_icon.swift -framework Cocoa 2>/dev/null
/tmp/create_icon "$ICONSET_DIR"

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"

rm -rf "$ICONSET_DIR"
rm -f /tmp/create_icon /tmp/create_icon.swift

echo "✅ Icon created: $RESOURCES_DIR/AppIcon.icns"


