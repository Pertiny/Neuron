import Foundation

class ChatStorage {
    private let key = "savedChats"
    
    func saveChats(_ chats: [ChatSession]) {
        do {
            let data = try JSONEncoder().encode(chats)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error saving chats: \(error)")
        }
    }
    
    func loadChats() -> [ChatSession] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        do {
            return try JSONDecoder().decode([ChatSession].self, from: data)
        } catch {
            print("Error loading chats: \(error)")
            return []
        }
    }
    
    func deleteChat(id: UUID) {
        var chats = loadChats()
        chats.removeAll { $0.id == id }
        saveChats(chats)
    }
}
