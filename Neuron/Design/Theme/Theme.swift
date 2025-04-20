//
//  Theme.swift
//  Neuron
//
//  Created by Jacques Zimmer on 20.04.25.
//


//
//  Theme.swift
//  Neuron
//

import SwiftUI
import Foundation


struct Theme {
    let type: ThemeType

    var customPrimaryColor: Color?
    var customBackgroundColor: Color?
    var customAccentColor: Color?
    var customSecondaryColor: Color?
    var customTextPrimaryColor: Color?
    var customTextSecondaryColor: Color?
    var customUseMonospacedFont: Bool?
    var customName: String?

    var primary: Color {
        customPrimaryColor ?? defaultColors.primary
    }

    var background: Color {
        customBackgroundColor ?? defaultColors.background
    }

    var accent: Color {
        customAccentColor ?? defaultColors.accent
    }

    var secondary: Color {
        customSecondaryColor ?? defaultColors.secondary
    }

    var textPrimary: Color {
        customTextPrimaryColor ?? defaultColors.textPrimary
    }

    var textSecondary: Color {
        customTextSecondaryColor ?? defaultColors.textSecondary
    }

    var colorScheme: ColorScheme? {
        if type == .custom {
            if let bg = customBackgroundColor, bg.brightness < 0.5 {
                return .dark
            } else {
                return .light
            }
        }

        switch type {
        case .terminal, .minimalDark: return .dark
        case .paper: return .light
        case .custom: return nil
        }
    }

    var titleFont: Font {
        useMonoFont ? .system(.title2, design: .monospaced) : .system(.title2, design: .rounded)
    }

    var bodyFont: Font {
        useMonoFont ? .system(.body, design: .monospaced) : .system(.body)
    }

    var captionFont: Font {
        useMonoFont ? .system(.caption, design: .monospaced) : .system(.caption)
    }

    var hasTerminalEffect: Bool {
        type == .terminal || (type == .custom && customUseMonospacedFont == true)
    }

    // MARK: - Private

    private var useMonoFont: Bool {
        type == .terminal || (type == .custom && customUseMonospacedFont == true)
    }

    private var defaultColors: (
        primary: Color,
        background: Color,
        accent: Color,
        secondary: Color,
        textPrimary: Color,
        textSecondary: Color
    ) {
        switch type {
        case .terminal:
            return (.customTerminalGreen, .black, .customTerminalGreen, .customTerminalGreen.opacity(0.6), .customTerminalGreen, .customTerminalGreen.opacity(0.7))
        case .minimalDark:
            return (.white, Color(hex: "#121212"), Color(hex: "#6C6C6C"), .gray, .white, .gray)
        case .paper:
            return (.black, .white, .blue, .gray, .black, .gray)
        case .custom:
            return (.blue, .white, .blue, .gray, .black, .gray)
        }
    }
}
