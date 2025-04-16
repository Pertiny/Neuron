import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
}

enum MessageRole: String, Codable {
    case user
    case assistant

    var textColor: Color {
        switch self {
        case .user:
            return Color(red: 127/255, green: 255/255, blue: 212/255)
        case .assistant:
            return .white
        }
    }
}
