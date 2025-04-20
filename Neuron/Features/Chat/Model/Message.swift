//
//  Message.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import Foundation

struct Message: Identifiable, Codable, Hashable {
    var id: UUID
    var role: Role
    var content: String
    var timestamp: Date
    
    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
    
    enum Role: String, Codable, CaseIterable {
        case system
        case assistant
        case user
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .assistant: return "AI"
            case .user: return "You"
            }
        }
        
        var iconName: String {
            switch self {
            case .system: return "gear"
            case .assistant: return "brain"
            case .user: return "person"
            }
        }
    }
}

// Erweiterungen für API
extension Message {
    // Konvertierung zu ChatGPT API Format
    var asChatGPTMessage: [String: String] {
        return [
            "role": role.rawValue,
            "content": content
        ]
    }
    
    // Erzeuge eine Systemanweisung
    static func systemPrompt(_ content: String) -> Message {
        Message(role: .system, content: content)
    }
}
