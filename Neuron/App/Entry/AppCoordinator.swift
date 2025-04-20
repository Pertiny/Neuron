//
//  AppCoordinator.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: Sheet?
    
    // Zentrale Definition aller Navigations-Routen
    enum Route: Hashable {
        case chatDetail(id: UUID)
        case settings
        case modelSelection
    }
    
    // Zentrale Definition aller modalen Sheet-Typen
    enum Sheet: Identifiable {
        case newChat
        case settings
        
        var id: String {
            switch self {
            case .newChat: return "newChat"
            case .settings: return "settings"
            }
        }
    }
    
    // Navigation innerhalb der NavigationStack
    func navigate(to route: Route) {
        path.append(route)
    }
    
    // Ein Level zurück in der Navigation
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    // Zurück zur Root-View
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // Sheet präsentieren
    func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }
    
    // Sheet schließen
    func dismissSheet() {
        presentedSheet = nil
    }
}
