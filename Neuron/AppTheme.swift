import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case neon = "Neon"
    case solarized = "Solarized"
    case midnight = "Midnight"

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .classic: return .black
        case .neon: return Color(red: 0.02, green: 0.02, blue: 0.08)
        case .solarized: return Color(red: 0.0, green: 0.168, blue: 0.211)
        case .midnight: return Color(red: 0.08, green: 0.1, blue: 0.2)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .classic: return .white
        case .neon: return Color.green
        case .solarized: return Color.orange
        case .midnight: return Color.cyan
        }
    }

    var accentColor: Color {
        switch self {
        case .classic: return .white
        case .neon: return Color.purple
        case .solarized: return Color.yellow
        case .midnight: return Color.indigo
        }
    }
}