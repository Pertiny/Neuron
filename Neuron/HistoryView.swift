import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var chats: [ChatSession] = []
    private let storage = ChatStorage()

    @State private var showAllChats = false

    @State private var folders: [String] = ["Archiv", "Papierkorb"]
    @State private var userFolders: [String] = []

    @State private var showAddFolderAlert = false
    @State private var newFolderName = ""

    private var latestChats: [ChatSession] {
        chats.filter { !$0.isArchived }
            .sorted(by: { $0.date > $1.date })
            .prefix(3)
            .map { $0 }
    }

    private var allFolders: [String] {
        let combined = Set(userFolders + folders)
        return Array(combined).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            BackHeaderView(title: "History") {
                dismiss()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header: Latest
                    Text("Latest")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)

                    // Drei neueste Chats
                    VStack(spacing: 12) {
                        ForEach(latestChats) { chat in
                            NavigationLink(destination: ChatView(loadedSession: chat)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chat.title)
                                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text(chat.date, style: .date)
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                    }

                    if chats.count > 3 {
                        Button("More") {
                            showAllChats = true
                        }
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    }

                    Divider()
                        .background(Color.gray)
                        .padding(.horizontal, 24)

                    // Ordnerüberschrift
                    HStack {
                        Text("Ordner")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            newFolderName = ""
                            showAddFolderAlert = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Benutzerdefinierte Ordner
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(userFolders, id: \.self) { folder in
                            NavigationLink(destination: AllChatsView(filterFolder: folder)) {
                                Text(folder)
                                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 4)
                            }
                        }
                    }

                    // Feste Ordner
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(folders, id: \.self) { folder in
                            NavigationLink(destination: AllChatsView(filterFolder: folder)) {
                                Text(folder)
                                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 4)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showAllChats) {
            NavigationView {
                AllChatsView()
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showAllChats = false
                            }) {
                                Text("<")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                            }
                        }
                    }
            }
            .preferredColorScheme(.dark)
        }
        .alert("Neuen Ordner erstellen", isPresented: $showAddFolderAlert, actions: {
            TextField("Ordnername", text: $newFolderName)
            Button("Abbrechen", role: .cancel) {}
            Button("Erstellen") {
                addNewFolder()
            }
        }, message: {
            Text("Gib einen Namen für den neuen Ordner ein.")
        })
        .onAppear {
            chats = storage.loadChats()
            userFolders = Array(Set(
                chats.compactMap { $0.folder }
                    .filter { $0 != "Archiv" && $0 != "Papierkorb" && $0 != "All" }
            )).sorted()
        }
    }

    private func addNewFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !userFolders.contains(trimmed) {
            userFolders.append(trimmed)
            userFolders.sort()
        }
    }
}
