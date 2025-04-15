import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    let loadedSession: ChatSession?
    
    @State private var messages: [ChatMessage] = []
    @State private var userPrompt: String = ""
    @StateObject private var apiManager = APIManager()
    
    @AppStorage("chatMaxTokens") private var maxTokens: Int = 512
    @AppStorage("chatTemperature") private var temperature: Double = 0.7
    
    init(loadedSession: ChatSession? = nil) {
        self.loadedSession = loadedSession
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { msg in
                                Text(msg.content)
                                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                                    .foregroundColor(msg.role.textColor)
                                    .frame(maxWidth: .infinity, alignment: msg.role == .user ? .trailing : .leading)
                                    .padding(.horizontal, 12)
                            }
                        }
                        .padding(.top, 16)
                    }
                    .onChange(of: messages.count) { oldCount, newCount in
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    saveCurrentChat()
                    dismiss()
                }) {
                    Text("<")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Chat")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ChatSettingsView()) {
                    Image(systemName: "gearshape")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
            }
        }
        .font(.system(size: 16, weight: .regular, design: .monospaced))
        .preferredColorScheme(.dark)
        .onAppear {
            if let session = loadedSession {
                messages = session.messages.map { simpleMsg in
                    ChatMessage(
                        role: simpleMsg.role == "user" ? .user : .assistant,
                        content: simpleMsg.content
                    )
                }
            }
        }
    }
    
    private func sendPrompt() {
        let cleanPrompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPrompt.isEmpty else { return }
        
        let userMsg = ChatMessage(role: .user, content: cleanPrompt)
        messages.append(userMsg)
        
        userPrompt = ""
        
        apiManager.sendRequest(
            prompt: cleanPrompt,
            apiKey: (UserDefaults.standard.string(forKey: "apiKey") ?? ""),
            maxTokens: maxTokens,
            temperature: temperature
        ) { response in
            DispatchQueue.main.async {
                let answer = response ?? "Keine Antwort"
                let assistantMsg = ChatMessage(role: .assistant, content: answer)
                messages.append(assistantMsg)
            }
        }
    }
    
    private func saveCurrentChat() {
        let simpleMessages = messages.map { msg in
            ChatMessageSimple(role: msg.role == .user ? "user" : "assistant", content: msg.content)
        }
        let title = messages.first(where: { $0.role == .user })?.content ?? "Chat vom \(Date().formatted(date: .numeric, time: .shortened))"
        
        let session = ChatSession(title: title, messages: simpleMessages)
        
        var existingChats = ChatStorage().loadChats()
        existingChats.insert(session, at: 0)
        ChatStorage().saveChats(existingChats)
    }
}
