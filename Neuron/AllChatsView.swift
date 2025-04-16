import SwiftUI

struct AllChatsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var chats: [ChatSession] = []
    private let storage = ChatStorage()

    var filterFolder: String? = nil

    var filteredChats: [ChatSession] {
        if let folder = filterFolder {
            return chats.filter { $0.folder == folder }
        } else {
            return chats
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            BackHeaderView(title: filterFolder ?? "All Chats") {
                dismiss()
            }

            List {
                ForEach(filteredChats) { chat in
                    NavigationLink(destination: ChatView(loadedSession: chat)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.title)
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: chat.title.count < 15 ? .infinity : 300, alignment: .leading)
                            Text(chat.date, style: .date)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteChats)
            }
            .listStyle(PlainListStyle())
            .background(Color.black)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .onAppear {
            chats = storage.loadChats()
        }
    }

    private func deleteChats(at offsets: IndexSet) {
        for index in offsets {
            let chat = filteredChats[index]
            storage.deleteChat(id: chat.id)
        }
        chats.remove(atOffsets: offsets)
    }
}
