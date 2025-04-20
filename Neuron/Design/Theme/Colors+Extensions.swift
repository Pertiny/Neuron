import SwiftUI

extension Color {
    // Terminal-Theme-Farben
    static let customTerminalGreen = Color(hex: "#00FF47")
        static let customTerminalDarkGreen = Color(hex: "#00CC59")
    
    // Farben für Minimal Dark Theme
    static let gray800 = Color(hex: "#1F1F1F")
    static let gray700 = Color(hex: "#2D2D2D")
    static let gray600 = Color(hex: "#393939")
    static let gray500 = Color(hex: "#5C5C5C")
    
    // Farben für Paper Theme
    static let paperWhite = Color(hex: "#FCFCFC")
    static let paperAccent = Color(hex: "#007AFF")
    
    // Generische semantische Farben
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FFC107")
    static let error = Color(hex: "#FF5252")
    
    // Hilfs-Initialisierer für Hex-Codes
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
