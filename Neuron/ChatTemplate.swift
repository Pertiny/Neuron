import Foundation

struct ChatTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var model: String
    var maxTokens: Int
    var temperature: Double
    var topP: Double
    var presencePenalty: Double
    var frequencyPenalty: Double
    var initialPrompt: String

    init(
        id: UUID = UUID(),
        title: String,
        model: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        presencePenalty: Double,
        frequencyPenalty: Double,
        initialPrompt: String
    ) {
        self.id = id
        self.title = title
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.initialPrompt = initialPrompt
    }
}