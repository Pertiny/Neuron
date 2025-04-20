import SwiftUI

final class ThemeManager: ObservableObject {
    // Verfügbare Themes
    enum ThemeType: String, CaseIterable, Identifiable {
        case terminal = "terminal"
        case minimalDark = "minimalDark"
        case paper = "paper"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .terminal: return "Terminal"
            case .minimalDark: return "Minimal Dark"
            case .paper: return "Paper"
            }
        }
    }

    // Speichert aktuelle Theme-Einstellung
    @AppStorage("app.selectedTheme") private var selectedThemeRaw: String = ThemeType.terminal.rawValue
    
    @Published var currentTheme: Theme
    
    init() {
        // Direkter Zugriff auf UserDefaults statt @AppStorage um self-access zu umgehen
        let storedThemeRaw = UserDefaults.standard.string(forKey: "app.selectedTheme") ?? ThemeType.terminal.rawValue
        let themeType = ThemeType(rawValue: storedThemeRaw) ?? .terminal
        self.currentTheme = Theme(type: themeType)
    }
    
    // Wechsel zu anderem Theme
    func switchTheme(to themeType: ThemeType) {
        currentTheme = Theme(type: themeType)
        selectedThemeRaw = themeType.rawValue
        applyCurrentTheme()
    }
    
    // Wende Theme-Einstellungen systemweit an
    func applyCurrentTheme() {
        // Hier könnten weitere globale UI-Anpassungen erfolgen
    }
}


// Theme-Struktur mit allen Design-Eigenschaften
struct Theme {
    let type: ThemeManager.ThemeType
    
    // Farben
    var primary: Color {
        switch type {
        case .terminal: return .terminalGreen
        case .minimalDark: return .white
        case .paper: return .black
        }
    }
    
    var background: Color {
        switch type {
        case .terminal: return .black
        case .minimalDark: return Color(hex: "#121212")
        case .paper: return .white
        }
    }
    
    var accent: Color {
        switch type {
        case .terminal: return .terminalGreen
        case .minimalDark: return Color(hex: "#6C6C6C") // Aus den Anforderungen
        case .paper: return .blue
        }
    }
    
    var secondary: Color {
        switch type {
        case .terminal: return .terminalGreen.opacity(0.6)
        case .minimalDark: return .gray
        case .paper: return .gray
        }
    }
    
    // Text-Farben
    var textPrimary: Color {
        switch type {
        case .terminal: return .terminalGreen
        case .minimalDark: return .white
        case .paper: return .black
        }
    }
    
    var textSecondary: Color {
        switch type {
        case .terminal: return .terminalGreen.opacity(0.7)
        case .minimalDark: return .gray
        case .paper: return .gray
        }
    }
    
    // System-Erscheinung
    var colorScheme: ColorScheme? {
        switch type {
        case .terminal, .minimalDark: return .dark
        case .paper: return .light
        }
    }
    
    // Fonts
    var titleFont: Font {
        switch type {
        case .terminal: return .system(.title2, design: .monospaced)
        default: return .system(.title2, design: .rounded)
        }
    }
    
    var bodyFont: Font {
        switch type {
        case .terminal: return .system(.body, design: .monospaced)
        default: return .system(.body)
        }
    }
    
    var captionFont: Font {
        switch type {
        case .terminal: return .system(.caption, design: .monospaced)
        default: return .system(.caption)
        }
    }
    
    // Theme-spezifische Effekte
    var hasTerminalEffect: Bool {
        type == .terminal
    }
}

// ViewModifier für zentrale Theme-Anwendung
struct ThemeModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
            .foregroundColor(themeManager.currentTheme.textPrimary)
            .font(themeManager.currentTheme.bodyFont)
            .background(themeManager.currentTheme.background)
            .tint(themeManager.currentTheme.accent)
            .conditionalTerminalEffect(isEnabled: themeManager.currentTheme.hasTerminalEffect)
    }
}

// Extension für einfache Theme-Anwendung
extension View {
    func themedView() -> some View {
        modifier(ThemeModifier())
    }
}
