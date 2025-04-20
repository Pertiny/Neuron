//
//  NeuronApp.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//

import SwiftUI

@main
struct NeuronApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .tint(themeManager.currentTheme.accent)
        }
    }
}
