import Foundation
import Carbon
import AppKit

class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    var onMultiTap: ((Int) -> Void)?
    
    private var tapCount = 0
    private var lastTapTime: Date?
    private var tapTimer: Timer?
    
    static let shared = HotkeyManager()
    
    private var tapInterval: TimeInterval {
        AppSettings.shared.tapInterval
    }
    
    private init() {}
    
    func start() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon!).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap. Grant Accessibility permissions.")
            showAccessibilityAlert()
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        print("Hotkey manager started. Multi-tap Fn to switch languages.")
    }
    
    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        // Fn key = 63 (kVK_Function)
        if keyCode == 63 && type == .keyDown {
            handleFnTap()
        }
        
        return Unmanaged.passRetained(event)
    }
    
    private func handleFnTap() {
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
                DispatchQueue.main.async {
                    self.onMultiTap?(self.tapCount)
                }
            }
            
            self.tapCount = 0
        }
    }
    
    private func showAccessibilityAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Требуется разрешение"
            alert.informativeText = "Добавьте приложение в System Settings → Privacy & Security → Accessibility"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Открыть настройки")
            alert.addButton(withTitle: "Отмена")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }
}
