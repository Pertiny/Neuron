import Foundation

class ChatStorage {
    private let key = "savedChats"

    func saveChats(_ chats: [ChatSession]) {
        do {
            let data = try JSONEncoder().encode(chats)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Fehler beim Speichern: \(error.localizedDescription)")
        }
    }

    func loadChats() -> [ChatSession] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
            return try JSONDecoder().decode([ChatSession].self, from: data)
        } catch {
            print("❌ Fehler beim Laden: \(error.localizedDescription)")
            return []
        }
    }

    func deleteChat(id: UUID) {
        var chats = loadChats()
        chats.removeAll { $0.id == id }
        saveChats(chats)
    }

    func updateChat(_ updated: ChatSession) {
        var chats = loadChats()
        if let index = chats.firstIndex(where: { $0.id == updated.id }) {
            chats[index] = updated
        } else {
            chats.insert(updated, at: 0)
        }
        saveChats(chats)
    }
}
