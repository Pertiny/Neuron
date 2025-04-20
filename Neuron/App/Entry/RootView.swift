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
            ChatListView()
                .navigationDestination(for: AppCoordinator.Route.self) { route in
                    switch route {
                    case .chatDetail(let id):
                        ChatDetailView(chatId: id)
                    case .settings:
                        SettingsView()
                    case .modelSelection:
                        EmptyView()
                        
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

// Diese Struktur ermöglicht Preview ohne App neu zu kompilieren
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
