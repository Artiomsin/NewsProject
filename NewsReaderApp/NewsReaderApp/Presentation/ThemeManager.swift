import UIKit

enum AppTheme: String {
    case system
    case light
    case dark
}

final class ThemeManager {
    static let shared = ThemeManager()
    
    private let themeKey = "appTheme"
    private(set) var currentTheme: AppTheme = .system
    
    private init() {
        loadSavedTheme()
    }
    
    func loadSavedTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
        applyTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
        applyTheme()
    }
    
    private func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else {
            return
        }
        
        windowScene.windows.forEach { window in
            switch currentTheme {
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            }
        }
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}


