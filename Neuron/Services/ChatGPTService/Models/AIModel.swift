//
//  AIModel.swift
//  Neuron
//
//  Created by Jacques Zimmer on 20.04.25.
//


//
//  AIModel.swift
//  Neuron
//
//  Created by Jacques Zimmer on 25.04.25.
//

import Foundation

struct AIModel: Identifiable, Equatable {
    var id: UUID
    var name: String
    var maxTokens: Int
    var description: String = ""
    var isAvailable: Bool = true
    
    static let mock: [AIModel] = [
        AIModel(id: UUID(), name: "GPT-3.5", maxTokens: 4096),
        AIModel(id: UUID(), name: "GPT-4", maxTokens: 8192),
        AIModel(id: UUID(), name: "Claude 2", maxTokens: 100000)
    ]
    
    // Standardmodell für neue Chats
    static var defaultModel: AIModel {
        mock.first ?? AIModel(id: UUID(), name: "Default Model", maxTokens: 4000)
    }
}
