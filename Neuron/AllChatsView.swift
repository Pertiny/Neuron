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
        NavigationView {
            List {
                ForEach(filteredChats) { chat in
                    NavigationLink(destination: ChatView(loadedSession: chat)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.title)
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            HStack {
                                Text(chat.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text(chat.date.formatted(date: .omitted, time: .shortened))
                            }
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete(perform: deleteChats)
            }
            .listStyle(PlainListStyle())
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(filterFolder ?? "All Chats")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(.white)
                }
            }
        }
        .navigationViewStyle(.stack)
        .background(Color.black.ignoresSafeArea())
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
        chats.removeAll { chat in
            offsets.contains { index in chat.id == filteredChats[index].id }
        }
    }
}
