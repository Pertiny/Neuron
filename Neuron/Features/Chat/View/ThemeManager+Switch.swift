// ThemeManager+Switch.swift

import SwiftUI

extension ThemeManager {
    func switchTheme(to type: ThemeType) {
        if type == .custom,
           let customThemeId = UserDefaults.standard.string(forKey: "app.customThemeId"),
           let customTheme = customThemes.first(where: { $0.id.uuidString == customThemeId }) {
            currentTheme = ThemeManager.createCustomTheme(from: customTheme)
        } else {
            currentTheme = Theme(type: type)
        }

        UserDefaults.standard.set(type.rawValue, forKey: "app.selectedTheme")
    }
}
