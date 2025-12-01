import AppKit
import SwiftUI
import UserNotifications

@main
struct MacLangToolsMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private let inputSourceManager = InputSourceManager()
    private let hotkeyManager = HotkeyManager.shared
    private let settings = AppSettings.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotkey()
        requestNotificationPermission()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let statusItem else { return }
        
        statusItem.behavior = [.removalAllowed]
        statusItem.isVisible = true
        statusItem.autosaveName = Bundle.main.bundleIdentifier ?? "MacLangTools.menu"
        
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "character.cursor.ibeam", accessibilityDescription: "MacLangTools") {
                image.isTemplate = true
                button.image = image
                button.image?.size = NSSize(width: 17, height: 17)
            } else {
                button.title = "⌥"
            }
            button.imagePosition = .imageOnly
            button.toolTip = "MacLangTools – Option key multi-tap"
        }
        
        rebuildMenu()
    }
    
    private func rebuildMenu() {
        let menu = NSMenu()
        
        let current = inputSourceManager.getCurrentInputSource() ?? "Unknown"
        let header = NSMenuItem(title: "Current: \(current)", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(NSMenuItem.separator())
        
        let doubleItem = NSMenuItem(title: "⌥×2 → \(settings.doubleTapLanguage.isEmpty ? "—" : settings.doubleTapLanguage)", action: nil, keyEquivalent: "")
        doubleItem.isEnabled = false
        menu.addItem(doubleItem)
        
        let tripleItem = NSMenuItem(title: "⌥×3 → \(settings.tripleTapLanguage.isEmpty ? "—" : settings.tripleTapLanguage)", action: nil, keyEquivalent: "")
        tripleItem.isEnabled = false
        menu.addItem(tripleItem)
        
        let quadItem = NSMenuItem(title: "⌥×4 → \(settings.quadTapLanguage.isEmpty ? "—" : settings.quadTapLanguage)", action: nil, keyEquivalent: "")
        quadItem.isEnabled = false
        menu.addItem(quadItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    private func setupHotkey() {
        hotkeyManager.onMultiTap = { [weak self] tapCount in
            self?.handleMultiTap(tapCount)
        }
        hotkeyManager.start()
    }
    
    private func handleMultiTap(_ count: Int) {
        let target: String?
        switch count {
        case 2:
            target = settings.doubleTapLanguage
        case 3:
            target = settings.tripleTapLanguage
        case 4...:
            target = settings.quadTapLanguage
        default:
            target = nil
        }
        
        guard let language = target, !language.isEmpty else { return }
        if inputSourceManager.switchToLanguage(language) {
            rebuildMenu()
            showNotification(title: "Language switched", body: language)
        }
    }
    
    @objc private func openSettings() {
        if settingsWindow == nil {
            let hosting = NSHostingView(rootView: SettingsView())
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 640),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "MacLangTools"
            window.contentView = hosting
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        hotkeyManager.stop()
        NSApp.terminate(nil)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
