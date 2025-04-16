import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var chats: [ChatSession] = []
    private let storage = ChatStorage()

    @State private var showAllChats = false
    @State private var showAddFolderAlert = false
    @State private var newFolderName = ""

    @State private var userFolders: [String] = []
    private let fixedFolders: [String] = ["Archiv", "Papierkorb"]

    private var latestChats: [ChatSession] {
        chats.filter { !$0.isArchived }
            .sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // MARK: - Ordnerbereich
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Ordner")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)

                            Spacer()

                            Button {
                                showAddFolderAlert = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(userFolders, id: \.self) { folder in
                                NavigationLink(destination: AllChatsView(filterFolder: folder)) {
                                    Text(folder)
                                        .font(.system(size: 16, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Divider()
                        .background(Color.gray)
                        .padding(.horizontal, 24)

                    // MARK: - Letzte Chats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Latest")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        ForEach(latestChats.prefix(10)) { chat in
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
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }

                        if chats.count > 10 {
                            Button("More") {
                                showAllChats = true
                            }
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(Color.black.ignoresSafeArea())
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
                    Text("History")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AllChatsView(filterFolder: "Archiv")) {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.white)
                    }

                    NavigationLink(destination: AllChatsView(filterFolder: "Papierkorb")) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showAllChats) {
                NavigationView {
                    AllChatsView()
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    showAllChats = false
                                } label: {
                                    Text("<")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                }
                .preferredColorScheme(.dark)
            }
            .alert("Neuen Ordner erstellen", isPresented: $showAddFolderAlert) {
                TextField("Ordnername", text: $newFolderName)
                Button("Abbrechen", role: .cancel) {}
                Button("Erstellen") { addNewFolder() }
            }
            .onAppear {
                chats = storage.loadChats()
                userFolders = Array(Set(
                    chats.compactMap { $0.folder }
                        .filter { !fixedFolders.contains($0) }
                )).sorted()
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
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
