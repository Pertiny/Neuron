import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject private var navigationModel: NavigationModel
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    
    @State private var loadedSession: ChatSession?
    @State private var chats: [ChatSession] = []

    @StateObject private var network = NetworkMonitor.shared
    private let storage = ChatStorage()

    private var recentChats: [ChatSession] {
        chats
            .filter { !$0.isArchived && ($0.folder ?? "").isEmpty }
            .sorted(by: { $0.date > $1.date })
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        let theme = selectedTheme

        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: UIApplication.shared.firstSafeAreaTop + 20)

                // MARK: - Header
                HStack {
                    Text("Neuron")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        navigationModel.navigateTo(.chat(nil))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)

                // MARK: - Chatliste
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recentChats) { chat in
                        HStack {
                            Text(chat.title)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Spacer()
                            
                            Menu {
                                Button {
                                    archiveChat(chat)
                                } label: {
                                    Label("Archivieren", systemImage: "archivebox")
                                }

                                Button(role: .destructive) {
                                    deleteChat(chat)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }

                                Button {
                                    // Optional: später erweitern
                                } label: {
                                    Label("In Ordner verschieben", systemImage: "folder")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 16))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigationModel.navigateTo(.chat(chat))
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }

                    // MARK: - Verlauf
                    Button {
                        navigationModel.navigateTo(.history)
                    } label: {
                        HStack(spacing: 4) {
                            Text("History")
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Spacer()

                // MARK: - Status
                VStack(spacing: 4) {
                    Text(UserDefaults.standard.string(forKey: "apiKey")?.isEmpty == false ? "API-Key aktiv" : "Kein API-Key")
                        .foregroundColor(Color.green)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    
                    Text(network.isConnected ? "Netzwerk verbunden" : "Kein Netzwerk")
                        .foregroundColor(Color.green)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                }
                .padding(.bottom, 24)

                // MARK: - Dock
                HStack {
                    Button {
                        navigationModel.navigateTo(.settings)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        navigationModel.navigateTo(.apiSettings)
                    } label: {
                        Image(systemName: "key.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, UIApplication.shared.firstSafeAreaBottom + 12)
            }
        }
        .onAppear {
            chats = storage.loadChats()
        }
        .navigationBarHidden(true)
    }

    private func deleteChat(_ chat: ChatSession) {
        withAnimation {
            storage.deleteChat(id: chat.id)
            chats = storage.loadChats()
        }
    }

    private func archiveChat(_ chat: ChatSession) {
        withAnimation {
            var updated = chat
            updated.isArchived = true
            storage.updateChat(updated)
            chats = storage.loadChats()
        }
    }
}
