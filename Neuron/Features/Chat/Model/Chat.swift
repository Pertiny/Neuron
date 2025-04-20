//
//  Chat.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import Foundation

struct Chat: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
    var modelId: String
    var isPinned: Bool
    
    // Berechnete Eigenschaften
    var isEmpty: Bool {
        messages.isEmpty
    }
    
    var wordCount: Int {
        messages.reduce(0) { count, message in
            count + message.content.split(separator: " ").count
        }
    }
    
    var lastMessagePreview: String {
        guard let lastMessage = messages.last else { return "" }
        let maxLength = 100
        if lastMessage.content.count > maxLength {
            return String(lastMessage.content.prefix(maxLength)) + "..."
        }
        return lastMessage.content
    }
    
    // Initialisierungen
    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        modelId: String = "gpt-3.5-turbo",
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.modelId = modelId
        self.isPinned = isPinned
    }
    
    // Hilfsmethoden
    mutating func addMessage(_ message: Message) {
        messages.append(message)
        updatedAt = Date()
    }
    
    mutating func clearMessages() {
        messages = []
        updatedAt = Date()
    }
    
    mutating func updateTitle(_ newTitle: String) {
        title = newTitle
        updatedAt = Date()
    }
    
    mutating func togglePin() {
        isPinned.toggle()
        updatedAt = Date()
    }
    
    func generateTitle() -> String {
        // Einfache Titelgenerierung basierend auf dem ersten Benutzer-Prompt
        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            let words = firstUserMessage.content.split(separator: " ")
            if words.count <= 5 {
                return firstUserMessage.content
            } else {
                return words.prefix(5).joined(separator: " ") + "..."
            }
        }
        return "New Chat"
    }
    
    // MARK: - Demo-Daten
    
    static var mockChats: [Chat] {
        [
            Chat(
                title: "Explaining Quantum Computing",
                messages: [
                    Message(role: .user, content: "Explain quantum computing to me like I'm 10 years old."),
                    Message(role: .assistant, content: "Imagine you have a magical coin that can be both heads AND tails at the same time until you look at it. Quantum computers use special bits like that magical coin, called qubits, which can be 0 and 1 at the same time. This lets them solve some super tricky problems much faster than regular computers!")
                ],
                modelId: "gpt-4"
            ),
            Chat(
                title: "Recipe Ideas",
                messages: [
                    Message(role: .user, content: "What can I cook with potatoes, carrots, and chicken?"),
                    Message(role: .assistant, content: "You could make:\n\n1. A hearty chicken stew with potatoes and carrots\n2. Roast chicken with potato and carrot wedges\n3. Chicken soup with potatoes and carrots\n4. Chicken pot pie with a potato topping\n5. One-pan chicken and root vegetable bake\n\nWould you like a specific recipe for any of these?")
                ],
                isPinned: true
            )
        ]
    }
}
