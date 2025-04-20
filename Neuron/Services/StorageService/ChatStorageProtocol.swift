//
//  ChatStorageProtocol.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import Foundation
import Combine

// Protocol für Dependency Injection und Tests
protocol ChatStorageProtocol {
    func loadAllChats() -> [Chat]
    func loadChat(id: UUID) -> Chat?
    func saveChat(_ chat: Chat) throws
    func deleteChat(id: UUID) throws
    func deleteAllChats() throws
    
    var chatsPublisher: AnyPublisher<[Chat], Never> { get }
}

final class ChatStorageService: ChatStorageProtocol, ObservableObject {
    // Singleton für einfachen globalen Zugriff
    static let shared = ChatStorageService()
    
    // Publizierter State
    @Published private(set) var chats: [Chat] = []
    
    // Zugriff über Publisher
    var chatsPublisher: AnyPublisher<[Chat], Never> {
        $chats.eraseToAnyPublisher()
    }
    
    // Storage Keys
    private enum StorageKeys {
        static let chatsKey = "neuron.storedChats"
    }
    
    // User Defaults für Persistenz
    private let defaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    private init() {
        loadChatsFromStorage()
    }
    
    // Initialisierung mit Test-Daten
    init(mockData: [Chat]) {
        self.chats = mockData
    }
    
    // MARK: - Public Methods
    
    func loadAllChats() -> [Chat] {
        return chats.sorted { 
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.updatedAt > $1.updatedAt
        }
    }
    
    func loadChat(id: UUID) -> Chat? {
        return chats.first { $0.id == id }
    }
    
    func saveChat(_ chat: Chat) throws {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index] = chat
        } else {
            chats.append(chat)
        }
        
        try saveChatsToDisk()
    }
    
    func deleteChat(id: UUID) throws {
        chats.removeAll { $0.id == id }
        try saveChatsToDisk()
    }
    
    func deleteAllChats() throws {
        chats.removeAll()
        try saveChatsToDisk()
    }
    
    // MARK: - Private Methods
    
    private func loadChatsFromStorage() {
        guard let data = defaults.data(forKey: StorageKeys.chatsKey) else {
            // Keine gespeicherten Chats, lade Demo-Daten für erste Benutzung
            #if DEBUG
            chats = Chat.mockChats
            #else
            chats = []
            #endif
            return
        }
        
        do {
            let decoder = JSONDecoder()
            chats = try decoder.decode([Chat].self, from: data)
        } catch {
            print("Fehler beim Laden der Chats: \(error)")
            chats = []
        }
    }
    
    private func saveChatsToDisk() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(chats)
        defaults.set(data, forKey: StorageKeys.chatsKey)
    }
    
    // MARK: - Helper Methods
    
    func filterChats(withMinWords minWordCount: Int = 0, searchQuery: String = "") -> [Chat] {
        let filteredByWord = chats.filter { $0.wordCount >= minWordCount }
        
        if searchQuery.isEmpty {
            return filteredByWord
        }
        
        return filteredByWord.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.messages.contains { msg in
                msg.content.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}

// Erweiterung für SwiftUI-Previews
extension ChatStorageService {
    static var preview: ChatStorageService {
        return ChatStorageService(mockData: Chat.mockChats)
    }
}
