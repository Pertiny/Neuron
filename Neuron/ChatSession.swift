import Foundation

struct ChatSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let messages: [ChatMessageSimple]
    
    var isArchived: Bool = false
    var folder: String? = nil
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         title: String,
         messages: [ChatMessageSimple],
         isArchived: Bool = false,
         folder: String? = nil) {
        
        self.id = id
        self.date = date
        self.title = title
        self.messages = messages
        self.isArchived = isArchived
        self.folder = folder
    }
}

struct ChatMessageSimple: Codable {
    let role: String // z. B. "user" oder "assistant"
    let content: String
}
