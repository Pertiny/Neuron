//
//  ThemeType.swift
//  Neuron
//

import SwiftUI

enum ThemeType: String, CaseIterable, Identifiable, Codable {
    case terminal
    case minimalDark
    case paper
    case custom

    var id: String { rawValue }

    /// Anzeigename für UI
    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .minimalDark: return "Minimal Dark"
        case .paper: return "Paper"
        case .custom: return "Custom"
        }
    }

    /// Vorschaufarbe oder symbolische Farbe
    var previewColor: Color {
        switch self {
        case .terminal: return .customTerminalGreen
        case .minimalDark: return .gray700
        case .paper: return .blue
        case .custom: return .purple
        }
    }

    /// Optional: SF Symbol für Theme-Auswahl
    var iconName: String {
        switch self {
        case .terminal: return "terminal"
        case .minimalDark: return "moon.fill"
        case .paper: return "doc.plaintext"
        case .custom: return "paintpalette"
        }
    }
}
