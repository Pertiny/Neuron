import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case classic
    // Hier deine anderen Theme-Fälle hinzufügen
    
    // Implementierung von Identifiable
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        // Weitere Fälle entsprechend behandeln
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .classic:
            return Color.black
        // Weitere Fälle entsprechend behandeln
        }
    }
    
    var accentColor: Color {
        switch self {
        case .classic:
            return Color.blue
        // Weitere Fälle entsprechend behandeln
        }
    }
    
    var textColor: Color {
        switch self {
        case .classic:
            return Color.white
        // Weitere Fälle entsprechend behandeln
        }
    }
    
    var primaryText: Color {
        switch self {
        case .classic:
            return Color.white
        // Weitere Fälle entsprechend behandeln
        }
    }
    
    // Neue Eigenschaft: secondaryText
    var secondaryText: Color {
        switch self {
        case .classic:
            return Color.gray // Üblich für sekundären Text
        // Weitere Fälle entsprechend behandeln
        }
    }
}
