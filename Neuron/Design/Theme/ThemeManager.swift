//
//  ThemeManager.swift
//  Neuron
//
//  Created by Jacques Zimmer on 20.04.25.
//


//
//  ThemeManager.swift
//  Neuron
//

import SwiftUI
import Foundation


final class ThemeManager: ObservableObject {
    @Published var customThemes: [CustomTheme] = []
    @Published var currentTheme: Theme

    @AppStorage("app.selectedTheme") private var selectedThemeRaw: String = ThemeType.terminal.rawValue

    init() {
        let loadedCustomThemes = ThemeManager.loadCustomThemesFromDisk()
        let storedThemeRaw = UserDefaults.standard.string(forKey: "app.selectedTheme") ?? ThemeType.terminal.rawValue
        let themeType = ThemeType(rawValue: storedThemeRaw) ?? .terminal

        if themeType == .custom,
           let customThemeId = UserDefaults.standard.string(forKey: "app.customThemeId"),
           let customTheme = loadedCustomThemes.first(where: { $0.id.uuidString == customThemeId }) {
            currentTheme = ThemeManager.createCustomTheme(from: customTheme)
        } else {
            currentTheme = Theme(type: themeType)
        }

        self.customThemes = loadedCustomThemes
    }

    // MARK: - Theme-Konvertierung

    static func createCustomTheme(from customTheme: CustomTheme) -> Theme {
        var theme = Theme(type: .custom)
        theme.customPrimaryColor = customTheme.primaryColor
        theme.customBackgroundColor = customTheme.backgroundColor
        theme.customAccentColor = customTheme.accentColor
        theme.customSecondaryColor = customTheme.secondaryColor
        theme.customTextPrimaryColor = customTheme.textPrimaryColor
        theme.customTextSecondaryColor = customTheme.textSecondaryColor
        theme.customUseMonospacedFont = customTheme.useMonospacedFont
        theme.customName = customTheme.name
        return theme
    }

    // MARK: - Theme-Persistenz

    func saveCustomThemesToDisk() {
        do {
            let data = try JSONEncoder().encode(customThemes)
            UserDefaults.standard.set(data, forKey: "app.customThemes")
        } catch {
            print("❌ Error saving custom themes: \(error)")
        }
    }

    private static func loadCustomThemesFromDisk() -> [CustomTheme] {
        guard let data = UserDefaults.standard.data(forKey: "app.customThemes") else { return [] }
        do {
            return try JSONDecoder().decode([CustomTheme].self, from: data)
        } catch {
            print("⚠️ Error loading custom themes: \(error)")
            return []
        }
    }
}
