import Foundation

struct ChatSession: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var title: String
    var messages: [ChatMessageSimple]

    var isArchived: Bool
    var folder: String? // z. B. „Projekt X“ oder „Papierkorb“

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String,
        messages: [ChatMessageSimple],
        isArchived: Bool = false,
        folder: String? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.messages = messages
        self.isArchived = isArchived
        self.folder = folder
    }
}

struct ChatMessageSimple: Codable, Equatable {
    let role: String // "user" oder "assistant"
    let content: String
}
