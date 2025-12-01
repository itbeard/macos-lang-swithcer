import SwiftUI
import UserNotifications

@main
struct VoiceLangSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var inputSourceManager: InputSourceManager!
    var hotkeyManager: HotkeyManager!
    var settings: AppSettings!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        inputSourceManager = InputSourceManager()
        hotkeyManager = HotkeyManager.shared
        settings = AppSettings.shared
        
        setupMenuBar()
        setupHotkey()
        requestNotificationPermission()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "MacLangTools")
        }
        
        updateMenu()
    }
    
    func updateMenu() {
        let menu = NSMenu()
        
        let currentLang = inputSourceManager.getCurrentInputSource() ?? "Unknown"
        menu.addItem(NSMenuItem(title: "Current: \(currentLang)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "⌥×2 → \(settings.doubleTapLanguage.isEmpty ? "—" : settings.doubleTapLanguage)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "⌥×3 → \(settings.tripleTapLanguage.isEmpty ? "—" : settings.tripleTapLanguage)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "⌥×4 → \(settings.quadTapLanguage.isEmpty ? "—" : settings.quadTapLanguage)", action: nil, keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        
        let exitItem = NSMenuItem(title: "Exit", action: #selector(quitApp), keyEquivalent: "q")
        exitItem.keyEquivalentModifierMask = []
        menu.addItem(exitItem)
        
        statusItem.menu = menu
    }
    
    private func setupHotkey() {
        hotkeyManager.onMultiTap = { [weak self] tapCount in
            self?.handleMultiTap(tapCount)
        }
        
        hotkeyManager.start()
    }
    
    private func handleMultiTap(_ count: Int) {
        var targetLanguage: String?
        
        switch count {
        case 2:
            targetLanguage = settings.doubleTapLanguage
        case 3:
            targetLanguage = settings.tripleTapLanguage
        case 4...:
            targetLanguage = settings.quadTapLanguage
        default:
            return
        }
        
        guard let language = targetLanguage, !language.isEmpty else { return }
        
        if inputSourceManager.switchToLanguage(language) {
            animateMenuBarIcon()
            updateMenu()
        }
    }
    
    private func animateMenuBarIcon() {
        guard let button = statusItem.button else { return }
        
        let originalImage = button.image
        button.image = NSImage(systemSymbolName: "globe.badge.chevron.backward", accessibilityDescription: nil)
        button.contentTintColor = .systemGreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            button.image = originalImage
            button.contentTintColor = nil
        }
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
    
    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        hotkeyManager.stop()
        NSApplication.shared.terminate(nil)
    }
}
