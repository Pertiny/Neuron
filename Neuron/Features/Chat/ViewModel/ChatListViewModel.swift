//
//  ChatListViewModel.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI
import Combine

final class ChatListViewModel: ObservableObject {
    // Publizierte Eigenschaften
    @Published var chats: [Chat] = []
    @Published var filteredChats: [Chat] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Dienste
    private let chatStorage: ChatStorageProtocol
    
    // Filter Einstellungen
    private var minWordCount = 20 // Gemäß Anforderung
    private var currentSearchQuery = ""
    
    // Subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(chatStorage: ChatStorageProtocol = ChatStorageService.shared) {
        self.chatStorage = chatStorage
        
        // Observer für Änderungen an Chats
        chatStorage.chatsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                self?.chats = chats
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadChats() {
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let allChats = self.chatStorage.loadAllChats()
            
            DispatchQueue.main.async {
                self.chats = allChats
                self.applyFilters()
                self.isLoading = false
            }
        }
    }
    
    func deleteChat(id: UUID) {
        do {
            try chatStorage.deleteChat(id: id)
            
            // Lokale UI aktualisieren
            self.chats.removeAll { $0.id == id }
            self.applyFilters()
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } catch {
            errorMessage = "Failed to delete chat: \(error.localizedDescription)"
        }
    }
    
    func togglePinChat(_ chat: Chat) {
        var updatedChat = chat
        updatedChat.togglePin()
        
        do {
            try chatStorage.saveChat(updatedChat)
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch {
            errorMessage = "Failed to update chat: \(error.localizedDescription)"
        }
    }
    
    func filterChats(searchQuery: String = "", minWords: Int? = nil) {
        currentSearchQuery = searchQuery
        
        if let minWords = minWords {
            minWordCount = minWords
        }
        
        applyFilters()
    }
    
    // MARK: - Private Methods
    
    private func applyFilters() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let filtered = self.chats
                .filter { $0.wordCount >= self.minWordCount }
                .filter {
                    if self.currentSearchQuery.isEmpty {
                        return true
                    }
                    return $0.title.localizedCaseInsensitiveContains(self.currentSearchQuery) ||
                           $0.messages.contains { message in
                               message.content.localizedCaseInsensitiveContains(self.currentSearchQuery)
                           }
                }
                .sorted {
                    // Gepinnte Chats zuerst
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned && !$1.isPinned
                    }
                    // Dann nach Datum sortieren
                    return $0.updatedAt > $1.updatedAt
                }
            
            DispatchQueue.main.async {
                self.filteredChats = filtered
            }
        }
    }
}
