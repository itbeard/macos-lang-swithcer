import Foundation
import Carbon
import AppKit
import ApplicationServices

class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var flagsMonitor: Any?
    private var localMonitor: Any?
    
    var onMultiTap: ((Int) -> Void)?
    
    private var tapCount = 0
    private var lastTapTime: Date?
    private var tapTimer: Timer?
    private var optionWasPressed = false
    
    static let shared = HotkeyManager()
    
    private var tapInterval: TimeInterval {
        AppSettings.shared.tapInterval
    }
    
    private init() {}
    
    func start() {
        if !AXIsProcessTrusted() {
            requestAccessibilityPermission()
            startPermissionPolling()
            return
        }
        
        setupEventMonitors()
    }
    
    private func requestAccessibilityPermission() {
        let hasPrompted = UserDefaults.standard.bool(forKey: "hasPromptedAccessibility")
        if !hasPrompted {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)
            UserDefaults.standard.set(true, forKey: "hasPromptedAccessibility")
        }
    }
    
    private func startPermissionPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if AXIsProcessTrusted() {
                timer.invalidate()
                self?.setupEventMonitors()
            }
        }
    }
    
    private func setupEventMonitors() {
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlags(event.modifierFlags)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlags(event.modifierFlags)
            return event
        }
    }
    
    func stop() {
        if let m = flagsMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        flagsMonitor = nil
        localMonitor = nil
    }
    
    private func handleFlags(_ flags: NSEvent.ModifierFlags) {
        let optionPressed = flags.contains(.option)
        
        if optionPressed && !optionWasPressed {
            handleOptionTap()
        }
        optionWasPressed = optionPressed
    }
    
    private func handleOptionTap() {
        let now = Date()
        
        tapTimer?.invalidate()
        
        if let lastTap = lastTapTime, now.timeIntervalSince(lastTap) < tapInterval {
            tapCount += 1
        } else {
            tapCount = 1
        }
        
        lastTapTime = now
        
        tapTimer = Timer.scheduledTimer(withTimeInterval: tapInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if self.tapCount >= 2 {
                self.onMultiTap?(self.tapCount)
            }
            
            self.tapCount = 0
        }
    }
}
