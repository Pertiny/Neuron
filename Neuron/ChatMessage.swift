import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
}

enum MessageRole {
    case user
    case assistant
    
    // Farbzuweisung passend zu Rolle
    var textColor: Color {
        switch self {
        case .user:
            return Color(red: 127/255, green: 255/255, blue: 212/255) // #7fffd4 Aquamarine
        case .assistant:
            return .white
        }
    }
}
