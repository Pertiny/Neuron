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
    @Published var currentFilter: ChatFilterOption = .all // Neues Filter-Feld
    
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
    
    // Hilfsmethode, um einen Chat-Parameter direkt zu übergeben
    func deleteChat(_ chat: Chat) {
        deleteChat(id: chat.id)
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
    
    // MARK: - Computed Properties für Kategorien
    
    // Hilfseigenschaften für Kategorie-Filter
    var pinnedChats: [Chat] {
        filteredChats.filter { $0.isPinned }
    }
    
    var unpinnedChats: [Chat] {
        filteredChats.filter { !$0.isPinned }
    }
    
    // MARK: - Helper Functions für Batch-Operationen
    
    func deleteChats(at indexSet: IndexSet, isPinned: Bool) {
        let chatsToDelete = isPinned ? pinnedChats : unpinnedChats
        
        for index in indexSet {
            if index < chatsToDelete.count {
                let chatToDelete = chatsToDelete[index]
                deleteChat(id: chatToDelete.id)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func applyFilters() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Erste Filterstufe: Wortanzahl und Suchbegriff
            var filtered = self.chats
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
            
            // Zweite Filterstufe: Kategorie-Filter
            switch self.currentFilter {
            case .all:
                // Alle Chats beibehalten
                break
            case .pinned:
                filtered = filtered.filter { $0.isPinned }
            case .recent:
                let calendar = Calendar.current
                let recentDate = calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date()
                filtered = filtered.filter { $0.updatedAt >= recentDate }
            }
            
            // Sortierung
            filtered = filtered.sorted {
                // Bei Kategorie-Filter "Pinned" keine Priorisierung nach Pin-Status
                if self.currentFilter != .pinned && $0.isPinned != $1.isPinned {
                    return $0.isPinned && !$1.isPinned
                }
                // Standard: Nach Datum sortieren
                return $0.updatedAt > $1.updatedAt
            }
            
            DispatchQueue.main.async {
                self.filteredChats = filtered
            }
        }
    }
}

// MARK: - Unterstützende Typen

// Enum für Chat-Filter
enum ChatFilterOption: String, CaseIterable, Identifiable {
    case all
    case pinned
    case recent
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "All Chats"
        case .pinned: return "Pinned"
        case .recent: return "Recent"
        }
    }
}
