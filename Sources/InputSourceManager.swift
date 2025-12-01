import Foundation
import Carbon

class InputSourceManager {
    
    func switchToRussian() -> Bool {
        switchToLanguage("Russian")
    }
    
    func switchToEnglish() -> Bool {
        switchToLanguage("English")
    }
    
    @discardableResult
    func switchToLanguage(_ language: String) -> Bool {
        guard let sources = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return false
        }
        
        let keywords = getKeywords(for: language)
        
        for source in sources {
            guard let sourceID = getProperty(source, kTISPropertyInputSourceID) as? String else {
                continue
            }
            
            let isSelectable = getProperty(source, kTISPropertyInputSourceIsSelectCapable) as? Bool ?? false
            guard isSelectable else { continue }
            
            let sourceName = getProperty(source, kTISPropertyLocalizedName) as? String ?? ""
            
            for keyword in keywords {
                if sourceID.localizedCaseInsensitiveContains(keyword) ||
                   sourceName.localizedCaseInsensitiveContains(keyword) {
                    TISSelectInputSource(source)
                    print("Switched to: \(sourceName) (\(sourceID))")
                    return true
                }
            }
        }
        
        print("Input source not found for: \(language)")
        return false
    }
    
    private func getKeywords(for language: String) -> [String] {
        let lowercased = language.lowercased()
        
        if lowercased.contains("russian") || lowercased.contains("русск") || lowercased.contains("рус") {
            return ["Russian", "Русская", "ru-RU", "ru"]
        } else if lowercased.contains("english") || lowercased.contains("англ") || lowercased.contains("eng") {
            return ["English", "ABC", "US", "en-US", "en"]
        } else if lowercased.contains("german") || lowercased.contains("немец") {
            return ["German", "Deutsch", "de"]
        } else if lowercased.contains("french") || lowercased.contains("франц") {
            return ["French", "Français", "fr"]
        } else if lowercased.contains("spanish") || lowercased.contains("испан") {
            return ["Spanish", "Español", "es"]
        } else if lowercased.contains("chinese") || lowercased.contains("китай") {
            return ["Chinese", "Pinyin", "zh"]
        } else if lowercased.contains("japanese") || lowercased.contains("японс") {
            return ["Japanese", "Hiragana", "ja"]
        } else if lowercased.contains("korean") || lowercased.contains("корей") {
            return ["Korean", "ko"]
        } else if lowercased.contains("ukrainian") || lowercased.contains("украин") {
            return ["Ukrainian", "Українська", "uk"]
        }
        
        return [language]
    }
    
    private func getProperty(_ source: TISInputSource, _ key: CFString) -> Any? {
        guard let ptr = TISGetInputSourceProperty(source, key) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue()
    }
    
    func getCurrentInputSource() -> String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }
        return getProperty(source, kTISPropertyLocalizedName) as? String
    }
    
    func listAvailableInputSources() -> [(name: String, id: String)] {
        guard let sources = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        
        var result: [(name: String, id: String)] = []
        for source in sources {
            let isSelectable = getProperty(source, kTISPropertyInputSourceIsSelectCapable) as? Bool ?? false
            guard isSelectable else { continue }
            
            if let name = getProperty(source, kTISPropertyLocalizedName) as? String,
               let id = getProperty(source, kTISPropertyInputSourceID) as? String {
                result.append((name: name, id: id))
            }
        }
        return result
    }
}
