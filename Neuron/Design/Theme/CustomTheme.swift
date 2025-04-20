import SwiftUI

struct CustomTheme: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String

    // HEX-repräsentierte Farben
    var primaryColorHex: String
    var backgroundColorHex: String
    var accentColorHex: String
    var secondaryColorHex: String
    var textPrimaryColorHex: String
    var textSecondaryColorHex: String

    var useMonospacedFont: Bool

    // Computed properties für einfachen Zugriff auf echte Colors
    var primaryColor: Color { Color(hex: primaryColorHex) ?? .blue }
    var backgroundColor: Color { Color(hex: backgroundColorHex) ?? .white }
    var accentColor: Color { Color(hex: accentColorHex) ?? .blue }
    var secondaryColor: Color { Color(hex: secondaryColorHex) ?? .gray }
    var textPrimaryColor: Color { Color(hex: textPrimaryColorHex) ?? .black }
    var textSecondaryColor: Color { Color(hex: textSecondaryColorHex) ?? .gray }

    // MARK: - Initializer

    init(name: String,
         primaryColor: Color,
         backgroundColor: Color,
         accentColor: Color,
         secondaryColor: Color,
         textPrimaryColor: Color,
         textSecondaryColor: Color,
         useMonospacedFont: Bool) {
        self.name = name
        self.primaryColorHex = primaryColor.toHex()
        self.backgroundColorHex = backgroundColor.toHex()
        self.accentColorHex = accentColor.toHex()
        self.secondaryColorHex = secondaryColor.toHex()
        self.textPrimaryColorHex = textPrimaryColor.toHex()
        self.textSecondaryColorHex = textSecondaryColor.toHex()
        self.useMonospacedFont = useMonospacedFont
    }

    // MARK: - Konvertierung

    func asStandardTheme() -> Theme {
        var theme = Theme(type: .custom)
        theme.customPrimaryColor = primaryColor
        theme.customBackgroundColor = backgroundColor
        theme.customAccentColor = accentColor
        theme.customSecondaryColor = secondaryColor
        theme.customTextPrimaryColor = textPrimaryColor
        theme.customTextSecondaryColor = textSecondaryColor
        theme.customUseMonospacedFont = useMonospacedFont
        theme.customName = name
        return theme
    }

    // MARK: - Vorlagen

    static func defaultTemplate() -> CustomTheme {
        return CustomTheme(
            name: "New Custom Theme",
            primaryColor: .blue,
            backgroundColor: .white,
            accentColor: .blue,
            secondaryColor: .gray,
            textPrimaryColor: .black,
            textSecondaryColor: .gray,
            useMonospacedFont: false
        )
    }

    static func terminalTemplate() -> CustomTheme {
        return CustomTheme(
            name: "Terminal Theme",
            primaryColor: .customTerminalGreen,
            backgroundColor: .black,
            accentColor: .customTerminalGreen,
            secondaryColor: .customTerminalGreen.opacity(0.6),
            textPrimaryColor: .customTerminalGreen,
            textSecondaryColor: .customTerminalGreen.opacity(0.7),
            useMonospacedFont: true
        )
    }
}
