import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var doubleTapLanguage: String {
        didSet { UserDefaults.standard.set(doubleTapLanguage, forKey: "doubleTapLanguage") }
    }
    
    @Published var tripleTapLanguage: String {
        didSet { UserDefaults.standard.set(tripleTapLanguage, forKey: "tripleTapLanguage") }
    }
    
    @Published var quadTapLanguage: String {
        didSet { UserDefaults.standard.set(quadTapLanguage, forKey: "quadTapLanguage") }
    }
    
    @Published var tapInterval: Double {
        didSet { UserDefaults.standard.set(tapInterval, forKey: "tapInterval") }
    }
    
    private init() {
        self.doubleTapLanguage = UserDefaults.standard.string(forKey: "doubleTapLanguage") ?? "Russian"
        self.tripleTapLanguage = UserDefaults.standard.string(forKey: "tripleTapLanguage") ?? "English"
        self.quadTapLanguage = UserDefaults.standard.string(forKey: "quadTapLanguage") ?? ""
        self.tapInterval = UserDefaults.standard.double(forKey: "tapInterval")
        if self.tapInterval == 0 { self.tapInterval = 0.3 }
    }
}

