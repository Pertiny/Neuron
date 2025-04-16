import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    @AppStorage("chatMaxTokens") private var maxTokens: Int = 512
    @AppStorage("chatTemperature") private var temperature: Double = 0.7
    @AppStorage("userTextColorHex") private var userTextColorHex: String = "#00FFCC"

    @StateObject private var apiManager = APIManager()
    @StateObject private var network = NetworkMonitor.shared

    let loadedSession: ChatSession?

    @State private var messages: [ChatMessage] = []
    @State private var userPrompt: String = ""
    @State private var animatedMessageIDs: Set<UUID> = []
    @State private var sessionTitle: String = ""
    @State private var showShareSheet = false
    @State private var showChatSettings = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                selectedTheme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    ConnectionBannerView(isConnected: network.isConnected)

                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(messages) { msg in
                                    ChatMessageView(
                                        message: msg,
                                        userTextColor: Color(hex: userTextColorHex),
                                        animatedMessageIDs: $animatedMessageIDs
                                    )
                                    .id(msg.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _, _ in
                            withAnimation {
                                if let lastID = messages.last?.id {
                                    scrollProxy.scrollTo(lastID, anchor: .bottom)
                                }
                            }
                        }
                    }

                    Divider().background(Color.gray)

                    HStack {
                        TextField("Deine Nachricht ...", text: $userPrompt)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)

                        Button(action: sendPrompt) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        saveSession()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }

                    Button {
                        showChatSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [exportText()])
            }
            .sheet(isPresented: $showChatSettings) {
                ChatSettingsView()
            }
            .onAppear {
                loadInitialSession()
            }
            .onDisappear {
                saveSession()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func sendPrompt() {
        let cleanPrompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPrompt.isEmpty else { return }

        let userMsg = ChatMessage(role: .user, content: cleanPrompt)
        messages.append(userMsg)
        userPrompt = ""

        apiManager.sendRequest(
            prompt: cleanPrompt,
            apiKey: UserDefaults.standard.string(forKey: "apiKey") ?? "",
            maxTokens: maxTokens,
            temperature: temperature
        ) { response in
            DispatchQueue.main.async {
                let answer = response ?? "[Systemfehler] Keine Antwort erhalten."
                let assistantMsg = ChatMessage(role: .assistant, content: answer)
                messages.append(assistantMsg)
            }
        }
    }

    private func saveSession() {
        let simpleMessages = messages.map {
            ChatMessageSimple(role: $0.role == .user ? "user" : "assistant", content: $0.content)
        }

        let title = sessionTitle.isEmpty
            ? messages.first(where: { $0.role == .user })?.content ?? "Chat vom \(Date().formatted(date: .numeric, time: .shortened))"
            : sessionTitle

        let updatedSession = ChatSession(
            id: loadedSession?.id ?? UUID(),
            date: Date(),
            title: title,
            messages: simpleMessages,
            isArchived: loadedSession?.isArchived ?? false,
            folder: loadedSession?.folder
        )

        var existingChats = ChatStorage().loadChats()
        existingChats.removeAll { $0.id == updatedSession.id }
        existingChats.insert(updatedSession, at: 0)
        ChatStorage().saveChats(existingChats)
    }

    private func loadInitialSession() {
        if let session = loadedSession {
            messages = session.messages.map {
                ChatMessage(role: $0.role == "user" ? .user : .assistant, content: $0.content)
            }
            sessionTitle = session.title
            animatedMessageIDs = Set(messages.map { $0.id })
        }
    }

    private func exportText() -> String {
        messages.map { "\($0.role == .user ? "User" : "Assistant"): \($0.content)" }
            .joined(separator: "\n\n")
    }
}
