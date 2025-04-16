import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case classic
    case neon
    case midnight
    case ocean
    case sunrise

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .classic: return .black
        case .neon: return Color(red: 0.05, green: 0.05, blue: 0.1)
        case .midnight: return Color(red: 0.1, green: 0.1, blue: 0.15)
        case .ocean: return Color(red: 0.05, green: 0.1, blue: 0.15)
        case .sunrise: return Color(red: 0.2, green: 0.1, blue: 0.05)
        }
    }

    var primaryText: Color {
        switch self {
        case .classic: return .white
        case .neon: return .green
        case .midnight: return .white
        case .ocean: return .cyan
        case .sunrise: return .orange
        }
    }

    var secondaryText: Color {
        switch self {
        case .classic: return .gray
        case .neon: return Color.green.opacity(0.7)
        case .midnight: return .gray
        case .ocean: return .blue
        case .sunrise: return Color.orange.opacity(0.7)
        }
    }

    var accentColor: Color {
        switch self {
        case .classic: return .white
        case .neon: return .green
        case .midnight: return .blue
        case .ocean: return .cyan
        case .sunrise: return .orange
        }
    }

    var buttonText: Color {
        switch self {
        case .classic: return .black
        case .neon: return .black
        case .midnight: return .white
        case .ocean: return .black
        case .sunrise: return .white
        }
    }

    var buttonBackground: Color {
        switch self {
        case .classic: return .white
        case .neon: return Color.green.opacity(0.8)
        case .midnight: return .blue
        case .ocean: return .cyan
        case .sunrise: return .orange
        }
    }
}
