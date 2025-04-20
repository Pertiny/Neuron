//
//  RootView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ChatListView() // Verwende deine bestehende ChatListView statt HomeView
                .navigationDestination(for: AppCoordinator.Route.self) { route in
                    switch route {
                    case .chatDetail(let id):
                        ChatDetailView(chatId: id)
                    case .settings:
                        SettingsView()
                    case .modelSelection:
                        Text("Model Selection") // Vorübergehend, bis du diese View implementiert hast
                    }
                }
                .sheet(item: $coordinator.presentedSheet) { sheet in
                    switch sheet {
                    case .newChat:
                        NewChatView()
                            .environmentObject(coordinator)
                            .environmentObject(themeManager)
                    case .settings:
                        SettingsView()
                            .environmentObject(coordinator)
                            .environmentObject(themeManager)
                    }
                }
        }
        .modifier(ThemeModifier())
        .environmentObject(coordinator)
        .environmentObject(themeManager)
    }
}
