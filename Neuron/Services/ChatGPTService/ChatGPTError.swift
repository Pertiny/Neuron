//
//  ChatGPTError.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import Foundation
import Combine

// Fehlertypen für API-Kommunikation
enum ChatGPTError: Error, LocalizedError {
    case invalidAPIKey
    case requestFailed(String)
    case parsingFailed
    case noResponse
    case rateLimited
    case connectionError
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .parsingFailed:
            return "Failed to parse API response."
        case .noResponse:
            return "No response from server."
        case .rateLimited:
            return "Rate limited by API. Please try again later."
        case .connectionError:
            return "Connection error. Please check your internet connection."
        }
    }
}

// Protocol für Dependency Injection und Tests
protocol ChatGPTServiceProtocol {
    func sendMessages(_ messages: [Message], model: String) async throws -> String
    var apiKey: String { get set }
}

final class ChatGPTService: ChatGPTServiceProtocol, ObservableObject {
    // Singleton für einfachen globalen Zugriff
    static let shared = ChatGPTService()
    
    // Publizierter State
    @Published var isLoading: Bool = false
    @Published var lastError: ChatGPTError?
    
    // API-Konfiguration
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let userDefaults = UserDefaults.standard
    private let apiKeyKey = "openai.apikey"
    
    var apiKey: String {
        get {
            userDefaults.string(forKey: apiKeyKey) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: apiKeyKey)
        }
    }
    
    private init() {}
    
    // Haupt-API-Methode
    func sendMessages(_ messages: [Message], model: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ChatGPTError.invalidAPIKey
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.lastError = nil
        }
        
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // API-Payload erstellen
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages.map { $0.asChatGPTMessage },
            "temperature": 0.7,
            "max_tokens": 2000
        ]
        
        // Request konfigurieren
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw ChatGPTError.parsingFailed
        }
        
        // Request senden
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatGPTError.noResponse
            }
            
            // Fehler-Handling basierend auf Status-Code
            switch httpResponse.statusCode {
            case 200:
                return try self.parseResponseContent(from: data)
            case 401:
                throw ChatGPTError.invalidAPIKey
            case 429:
                throw ChatGPTError.rateLimited
            default:
                let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data).error.message
                throw ChatGPTError.requestFailed(errorMessage ?? "Status code: \(httpResponse.statusCode)")
            }
        } catch let error as ChatGPTError {
            DispatchQueue.main.async {
                self.lastError = error
            }
            throw error
        } catch {
            let chatError = ChatGPTError.connectionError
            DispatchQueue.main.async {
                self.lastError = chatError
            }
            throw chatError
        }
    }
    
    // Antwort parsen
    private func parseResponseContent(from data: Data) throws -> String {
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(ChatGPTResponse.self, from: data)
            guard let content = response.choices.first?.message.content else {
                throw ChatGPTError.parsingFailed
            }
            return content
        } catch {
            throw ChatGPTError.parsingFailed
        }
    }
    
    // API-Modelle
    private struct ChatGPTResponse: Decodable {
        let choices: [Choice]
        
        struct Choice: Decodable {
            let message: MessageResponse
        }
        
        struct MessageResponse: Decodable {
            let content: String
        }
    }
    
    private struct ErrorResponse: Decodable {
        let error: ErrorDetail
        
        struct ErrorDetail: Decodable {
            let message: String
        }
    }
}

// Erweiterung für Mocking in Tests und Previews
extension ChatGPTService {
    static func mockService() -> MockChatGPTService {
        return MockChatGPTService()
    }
}

class MockChatGPTService: ChatGPTServiceProtocol {
    var apiKey: String = "mock-key"
    var mockResponses: [String] = [
        "I'm a simulated AI response for testing purposes.",
        "This is a mock response to help with UI development.",
        "No actual API calls are being made in preview mode."
    ]
    
    func sendMessages(_ messages: [Message], model: String) async throws -> String {
        // Simuliere Netzwerkverzögerung
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Gib eine zufällige Antwort zurück
        return mockResponses.randomElement() ?? "Mock response"
    }
}
