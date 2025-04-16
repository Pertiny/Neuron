import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case light = "Hell"
    case dark = "Dunkel"
    case system = "System"

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}