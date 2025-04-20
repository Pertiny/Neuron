//
//  ThemeModifier.swift
//  Neuron
//
//  Created by Jacques Zimmer on 20.04.25.
//


//
//  ThemeModifier.swift
//  Neuron
//

import SwiftUI
import Foundation


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

extension View {
    func themedView() -> some View {
        modifier(ThemeModifier())
    }
}
