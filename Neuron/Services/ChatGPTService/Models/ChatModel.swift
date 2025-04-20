//
//  ChatModel.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import Foundation

// Modell-Definitionen
struct ChatModel: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var maxTokens: Int
    var costPer1KTokens: Double
    var contextWindow: Int
    var category: Category
    
    enum Category: String, Codable, CaseIterable {
        case standard
        case premium
        
        var displayName: String {
            switch self {
            case .standard: return "Standard"
            case .premium: return "Premium"
            }
        }
    }
    
    var supportsVision: Bool {
        return ["gpt-4-vision-preview", "gpt-4-turbo"].contains(id)
    }
    
    var formattedCost: String {
        return String(format: "$%.3f per 1K tokens", costPer1KTokens)
    }
    
    static let availableModels: [ChatModel] = [
        ChatModel(
            id: "gpt-3.5-turbo",
            name: "GPT-3.5 Turbo",
            description: "Standard model with good balance of intelligence and speed",
            maxTokens: 4096,
            costPer1KTokens: 0.002,
            contextWindow: 4096,
            category: .standard
        ),
        ChatModel(
            id: "gpt-4",
            name: "GPT-4",
            description: "Most powerful model for complex tasks",
            maxTokens: 8192,
            costPer1KTokens: 0.06,
            contextWindow: 8192,
            category: .premium
        ),
        ChatModel(
            id: "gpt-4-turbo",
            name: "GPT-4 Turbo",
            description: "Latest model with improved reasoning abilities",
            maxTokens: 128000,
            costPer1KTokens: 0.01,
            contextWindow: 128000,
            category: .premium
        )
    ]
    
    static func getModel(for id: String) -> ChatModel {
        availableModels.first { $0.id == id } ?? availableModels[0]
    }
}
