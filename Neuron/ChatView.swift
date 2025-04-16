import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    @AppStorage("chatMaxTokens") private var maxTokens: Int = 512
    @AppStorage("chatTemperature") private var temperature: Double = 0.7
    @AppStorage("userTextColorHex") private var userTextColorHex: String = "#00FFCC"

    @StateObject private var apiManager = APIManager()
    @StateObject private var network = NetworkMonitor.shared

    @State private var showSettings = false

    let loadedSession: ChatSession?

    @State private var messages: [ChatMessage] = []
    @State private var userPrompt: String = ""
    @State private var animatedMessageIDs: Set<UUID> = []

    init(loadedSession: ChatSession? = nil) {
        self.loadedSession = loadedSession
    }

    var body: some View {
        let theme = selectedTheme

        ZStack(alignment: .top) {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // ⬇️ Banner immer mit fester Höhe (sichtbar/unsichtbar)
                ConnectionBannerView(isConnected: network.isConnected)
                    .frame(height: 28)

                // ⬇️ Header bleibt immer oben
                HStack {
                    Button(action: {
                        saveCurrentChat()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                    }

                    Spacer()

                    Text("Chat")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))

                    Spacer()

                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.trailing, 16)
                    }
                }
                .frame(height: 44)
                .background(Color.black)

                // ⬇️ Nachrichten
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
                        .padding(.horizontal)
                        .padding(.bottom, 8)
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

                // ⬇️ Eingabezeile
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
        .fullScreenCover(isPresented: $showSettings) {
            ChatSettingsView()
        }
        .navigationBarHidden(true)
        .onAppear {
            if let session = loadedSession {
                messages = session.messages.map {
                    ChatMessage(
                        role: MessageRole(rawValue: $0.role) ?? .assistant,
                        content: $0.content
                    )
                }
                animatedMessageIDs = Set(messages.map { $0.id })
            }
        }
    }

    // MARK: - Actions
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

    private func saveCurrentChat() {
        let simpleMessages = messages.map {
            ChatMessageSimple(role: $0.role == .user ? "user" : "assistant", content: $0.content)
        }

        let title = messages.first(where: { $0.role == .user })?.content
            ?? "Chat vom \(Date().formatted(date: .numeric, time: .shortened))"

        let session = ChatSession(title: title, messages: simpleMessages)
        var existingChats = ChatStorage().loadChats()
        existingChats.insert(session, at: 0)
        ChatStorage().saveChats(existingChats)
    }
}
