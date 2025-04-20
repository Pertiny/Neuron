//
//  ChatDetailViewModel.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI
import Combine

final class ChatDetailViewModel: ObservableObject {
    // Publizierte Eigenschaften
    @Published var chat: Chat?
    @Published var userInput = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var tokenCount = 0
    @Published var percentOfMaxTokens: CGFloat = 0
    
    // Dienste
    private let chatStorage: ChatStorageProtocol
    private let chatGPT: ChatGPTServiceProtocol
    
    // Tracking für Tastatur
    @Published var keyboardHeight: CGFloat = 0
    
    // Chat ID
    let chatId: UUID
    
    // Aktuelle einstellungen für den Chat
    private(set) var selectedModel: ChatModel
    
    // MARK: - Lifecycle
    
    init(
        chatId: UUID,
        chatStorage: ChatStorageProtocol = ChatStorageService.shared,
        chatGPT: ChatGPTServiceProtocol = ChatGPTService.shared
    ) {
        self.chatId = chatId
        self.chatStorage = chatStorage
        self.chatGPT = chatGPT
        
        // Default-Modell laden
        self.selectedModel = ChatModel.getModel(for: "gpt-3.5-turbo")
        
        // Chat laden
        loadChat()
        
        // Keyboard-Beobachter einrichten
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func loadChat() {
        chat = chatStorage.loadChat(id: chatId)
        
        if let model = chat?.modelId {
            selectedModel = ChatModel.getModel(for: model)
        }
        
        calculateTokens()
    }
    
    func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let userMessage = Message(role: .user, content: userInput)
        userInput = ""
        
        // Chat updaten
        updateChat(adding: userMessage)
        
        // API Request vorbereiten
        Task {
            await sendToAPI()
        }
        
        // Haptisches Feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func clearChat() {
        guard var chatCopy = chat else { return }
        chatCopy.clearMessages()
        
        do {
            try chatStorage.saveChat(chatCopy)
            chat = chatCopy
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } catch {
            errorMessage = "Failed to clear chat: \(error.localizedDescription)"
        }
    }
    
    func deleteChat() {
        do {
            try chatStorage.deleteChat(id: chatId)
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } catch {
            errorMessage = "Failed to delete chat: \(error.localizedDescription)"
        }
    }
    
    func togglePinChat() {
        guard var chatCopy = chat else { return }
        chatCopy.togglePin()
        
        do {
            try chatStorage.saveChat(chatCopy)
            chat = chatCopy
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch {
            errorMessage = "Failed to update chat: \(error.localizedDescription)"
        }
    }
    
    func updateTitle(_ newTitle: String) {
        guard var chatCopy = chat else { return }
        chatCopy.updateTitle(newTitle)
        
        do {
            try chatStorage.saveChat(chatCopy)
            chat = chatCopy
        } catch {
            errorMessage = "Failed to update chat title: \(error.localizedDescription)"
        }
    }
    
    func changeModel(to modelId: String) {
        selectedModel = ChatModel.getModel(for: modelId)
        
        guard var chatCopy = chat else { return }
        chatCopy.modelId = modelId
        
        do {
            try chatStorage.saveChat(chatCopy)
            chat = chatCopy
        } catch {
            errorMessage = "Failed to update chat model: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Private Methods
    
    private func updateChat(adding message: Message) {
        guard var chatCopy = chat else {
            // Neuen Chat erstellen, falls keiner existiert
            let newChat = Chat(
                id: chatId,
                title: "New Chat",
                messages: [message],
                modelId: selectedModel.id
            )
            
            do {
                try chatStorage.saveChat(newChat)
                chat = newChat
            } catch {
                errorMessage = "Failed to create chat: \(error.localizedDescription)"
            }
            return
        }
        
        // Existierenden Chat aktualisieren
        chatCopy.addMessage(message)
        
        // Titel aus erstem Benutzertext generieren, falls nicht angepasst
        if chatCopy.title == "New Chat" && message.role == .user {
            chatCopy.title = chatCopy.generateTitle()
        }
        
        do {
            try chatStorage.saveChat(chatCopy)
            chat = chatCopy
        } catch {
            errorMessage = "Failed to update chat: \(error.localizedDescription)"
        }
        
        calculateTokens()
    }
    
    private func sendToAPI() async {
        guard var currentChat = chat, !currentChat.messages.isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await chatGPT.sendMessages(currentChat.messages, model: selectedModel.id)
            
            // Antwort des Assistenten hinzufügen
            let assistantMessage = Message(
                role: .assistant,
                content: response.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            // Auf Main-Thread UI aktualisieren
            await MainActor.run {
                updateChat(adding: assistantMessage)
                isLoading = false
            }
        } catch let error as ChatGPTError {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Unknown error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
    }
    
    // Token-Kalkulation
    private func calculateTokens() {
        guard let chat = chat else {
            tokenCount = 0
            percentOfMaxTokens = 0
            return
        }
        
        // Einfache Approximation: ~4 Zeichen ≈ 1 Token
        let allText = chat.messages.reduce("") { $0 + $1.content }
        let approximateTokens = allText.count / 4
        
        tokenCount = approximateTokens
        percentOfMaxTokens = min(CGFloat(approximateTokens) / CGFloat(selectedModel.maxTokens), 1.0)
    }
}
