//
//  Color+Extensions.swift
//  Neuron
//
//  Created by Jacques Zimmer on 25.04.25.
//

import SwiftUI
import Foundation

extension Color {
    // MARK: - Terminal-Theme-Farben
    static let customTerminalGreen = Color(hex: "#00FF47")
    static let customTerminalDarkGreen = Color(hex: "#00CC59")

    // MARK: - Minimal Dark Theme
    static let gray800 = Color(hex: "#1F1F1F")
    static let gray700 = Color(hex: "#2D2D2D")
    static let gray600 = Color(hex: "#393939")
    static let gray500 = Color(hex: "#5C5C5C")

    // MARK: - Paper Theme
    static let paperWhite = Color(hex: "#FCFCFC")
    static let paperAccent = Color(hex: "#007AFF")

    // MARK: - Semantic Colors
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FFC107")
    static let error = Color(hex: "#FF5252")

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
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

    // MARK: - Convert to Hex
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components.count >= 4 ? components[3] : 1.0

        if a == 1.0 {
            return String(format: "#%02lX%02lX%02lX",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255),
                          Int(a * 255))
        }
    }

    // MARK: - Helligkeit / Luminanz
    var brightness: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Wahrgenommene Helligkeit (YIQ)
        return (red * 299 + green * 587 + blue * 114) / 1000
    }

    var luminance: CGFloat {
        brightness // Alias für semantische Lesbarkeit
    }

    // MARK: - Beschreibung für UI-Zwecke
    var simpleDescription: String {
        if self == .black { return "Black" }
        if self == .white { return "White" }
        if self == .red { return "Red" }
        if self == .orange { return "Orange" }
        if self == .yellow { return "Yellow" }
        if self == .green { return "Green" }
        if self == .blue { return "Blue" }
        if self == .purple { return "Purple" }
        if self == .gray { return "Gray" }
        if self == .customTerminalGreen { return "Terminal Green" }
        return "Custom"
    }
}
