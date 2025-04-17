import SwiftUI

// Ein einheitlicher Typ für die Navigation
enum NeuronDestination: Hashable, Identifiable {
    case chat(ChatSession?)
    case history
    case settings
    case chatSettings
    case apiSettings
    
    var id: String {
        switch self {
        case .chat(let session):
            // session ist optional, aber session.id ist nicht optional
            return "chat-\(session?.id.uuidString ?? "new")"
        case .history:
            return "history"
        case .settings:
            return "settings"
        case .chatSettings:
            return "chatSettings"
        case .apiSettings:
            return "apiSettings"
        }
    }
    
    // Hashable-Konformität
    func hash(into hasher: inout Hasher) {
        switch self {
        case .chat(let session):
            hasher.combine(0)
            if let session = session {
                hasher.combine(session.id)
            } else {
                hasher.combine("new")
            }
        case .history:
            hasher.combine(1)
        case .settings:
            hasher.combine(2)
        case .chatSettings:
            hasher.combine(3)
        case .apiSettings:
            hasher.combine(4)
        }
    }
    
    static func == (lhs: NeuronDestination, rhs: NeuronDestination) -> Bool {
        switch (lhs, rhs) {
        case (.chat(let lhs), .chat(let rhs)):
            return lhs?.id == rhs?.id
        case (.history, .history):
            return true
        case (.settings, .settings):
            return true
        case (.chatSettings, .chatSettings):
            return true
        case (.apiSettings, .apiSettings):
            return true
        default:
            return false
        }
    }
}

// Unser Navigationsmodell
class NavigationModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: NeuronDestination?
    
    func navigateTo(_ destination: NeuronDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path = NavigationPath()
    }
    
    func presentSheet(_ destination: NeuronDestination?) {
        presentedSheet = destination
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
}
