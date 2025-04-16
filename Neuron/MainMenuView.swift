
import SwiftUI

struct MainMenuView: View {
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    @State private var showNewChat = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showAPISettings = false

    @StateObject private var network = NetworkMonitor.shared
    @State private var recentChats: [ChatSession] = []

    private let storage = ChatStorage()

    var body: some View {
        let theme = selectedTheme

        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: UIApplication.shared.firstSafeAreaTop + 16)

                // Header
                HStack {
                    Text("Neuron")
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        showNewChat = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(recentChats.prefix(3)) { chat in
                        HStack(alignment: .center) {
                            Button {
                                showChat(chat)
                            } label: {
                                HStack {
                                    Text(chat.title)
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(chat.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundColor(.gray)
                                        Text(chat.date.formatted(date: .omitted, time: .shortened))
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                            }

                            Menu {
                                Button("Löschen", role: .destructive) {
                                    deleteChat(chat)
                                }

                                Button("Archivieren") {
                                    archiveChat(chat)
                                }

                                Button("In Ordner verschieben") {
                                    // komm später
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Button {
                        showHistory = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("History")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 24)

                    Rectangle()
                        .frame(height: 1)
                        .frame(maxWidth: 64)
                        .foregroundColor(.gray.opacity(0.2))
                        .padding(.horizontal, 24)
                }
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 4) {
                    Text(UserDefaults.standard.string(forKey: "apiKey")?.isEmpty == false ? "API–Key aktiv" : "Kein API–Key")
                    Text(network.isConnected ? "Netzwerk verbunden" : "Kein Netzwerk")
                }
                .foregroundColor(.green)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .padding(.bottom, 16)

                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        showAPISettings = true
                    } label: {
                        Image(systemName: "key.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, UIApplication.shared.firstSafeAreaBottom + 12)
            }
        }
        .fullScreenCover(isPresented: $showNewChat) {
            ChatView(loadedSession: nil)
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            GeneralSettingsView()
        }
        .fullScreenCover(isPresented: $showAPISettings) {
            GeneralSettingsView()
        }
        .onAppear {
            recentChats = ChatStorage().loadChats()
                .filter { !$0.isArchived }
                .sorted(by: { $0.date > $1.date })
        }
    }

    private func showChat(_ chat: ChatSession) {
        showNewChat = true
    }

    private func deleteChat(_ chat: ChatSession) {
        ChatStorage().deleteChat(id: chat.id)
        recentChats.removeAll { $0.id == chat.id }
    }

    private func archiveChat(_ chat: ChatSession) {
        var updated = chat
        updated.isArchived = true
        ChatStorage().updateChat(updated)
        recentChats.removeAll { $0.id == chat.id }
    }
}
