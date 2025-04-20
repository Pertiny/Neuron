import Foundation

// MARK: - API Request Models

struct ChatGPTRequest: Encodable {
    let model: String
    let messages: [APIMessage]
    let temperature: Double
    let max_tokens: Int
    let stream: Bool?
    
    struct APIMessage: Encodable {
        let role: String
        let content: MessageContent
        
        enum MessageContent: Encodable {
            case text(String)
            case multimodal([ContentPart])
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .text(let string):
                    try container.encode(string)
                case .multimodal(let parts):
                    try container.encode(parts)
                }
            }
        }
        
        struct ContentPart: Encodable {
            let type: String
            let text: String?
            let image_url: ImageURL?
            
            struct ImageURL: Encodable {
                let url: String
                let detail: String?
            }
        }
    }
    
    init(
        model: String,
        messages: [Message],
        temperature: Double = 0.7,
        maxTokens: Int = 2000,
        stream: Bool? = nil
    ) {
        self.model = model
        self.messages = messages.map { message in
            APIMessage(
                role: message.role.rawValue,
                content: .text(message.content)
            )
        }
        self.temperature = temperature
        self.max_tokens = maxTokens
        self.stream = stream
    }
    
    // Hilfsmethode um Multimodal-Nachrichten zu erstellen (z.B. für Bilder)
    static func withImage(
        model: String,
        textPrompt: String,
        imageURLs: [String],
        imageDetail: String = "auto"
    ) -> ChatGPTRequest {
        let textPart = APIMessage.ContentPart(
            type: "text",
            text: textPrompt,
            image_url: nil
        )
        
        let imageParts = imageURLs.map { url in
            APIMessage.ContentPart(
                type: "image_url",
                text: nil,
                image_url: APIMessage.ContentPart.ImageURL(
                    url: url,
                    detail: imageDetail
                )
            )
        }
        
        let contentParts = [textPart] + imageParts
        
        let message = APIMessage(
            role: "user",
            content: .multimodal(contentParts)
        )
        
        return ChatGPTRequest(
            model: model,
            messages: [],
            temperature: 0.7,
            maxTokens: 2000,
            stream: nil
        )
    }
}

// MARK: - API Response Models

struct ChatGPTResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Decodable {
        let index: Int
        let message: Message
        let finish_reason: String?
        
        struct Message: Decodable {
            let role: String
            let content: String
        }
    }
    
    struct Usage: Decodable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}

// MARK: - Streaming Response Model

struct ChatGPTStreamResponse: Decodable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [Choice]?
    
    struct Choice: Decodable {
        let index: Int?
        let delta: Delta?
        let finish_reason: String?
        
        struct Delta: Decodable {
            let role: String?
            let content: String?
        }
    }
}

// MARK: - Error Response Model

struct ChatGPTErrorResponse: Decodable {
    let error: ErrorDetails
    
    struct ErrorDetails: Decodable {
        let message: String
        let type: String
        let param: String?
        let code: String?
    }
}

// MARK: - Konversions-Erweiterungen

extension Message {
    /// Konvertiere in ChatGPT API Message mit optionalem Bild-Support
    func toAPIMessage(imageURLs: [String]? = nil) -> ChatGPTRequest.APIMessage {
        if let imageURLs = imageURLs, !imageURLs.isEmpty {
            let textPart = ChatGPTRequest.APIMessage.ContentPart(
                type: "text",
                text: content,
                image_url: nil
            )
            
            let imageParts = imageURLs.map { url in
                ChatGPTRequest.APIMessage.ContentPart(
                    type: "image_url",
                    text: nil,
                    image_url: ChatGPTRequest.APIMessage.ContentPart.ImageURL(
                        url: url,
                        detail: "auto"
                    )
                )
            }
            
            let contentParts = [textPart] + imageParts
            return ChatGPTRequest.APIMessage(
                role: role.rawValue,
                content: .multimodal(contentParts)
            )
            
        } else {
            return ChatGPTRequest.APIMessage(
                role: role.rawValue,
                content: .text(content)
            )
        }
    }
}

extension ChatGPTResponse {
    /// Konvertiere API-Antwort in eine Message
    var asMessage: Message? {
        guard let choice = choices.first,
              let role = Message.Role(rawValue: choice.message.role) else {
            return nil
        }
        
        return Message(
            role: role,
            content: choice.message.content
        )
    }
    
    /// Extrahiere Token-Nutzung
    var tokenUsage: (prompt: Int, completion: Int, total: Int)? {
        guard let usage = usage else { return nil }
        return (usage.prompt_tokens, usage.completion_tokens, usage.total_tokens)
    }
}
