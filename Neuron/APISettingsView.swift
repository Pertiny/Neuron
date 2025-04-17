import SwiftUI

struct APISettingsView: View {
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("openAIOrgID") private var openAIOrgID: String = ""
    @State private var newAPIKey: String = ""
    @State private var showingInfo: [String: Bool] = [:]
    @StateObject private var apiManager = APIManager()
    @State private var availableModels: [String] = []
    @State private var showingAlert = false
    
    private let fallbackModels = [
        "gpt-3.5-turbo", "gpt-3.5-turbo-16k",
        "gpt-4", "gpt-4-32k", "gpt-4-0613", "gpt-4-turbo", "gpt-4o"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - API Key
                settingBlock(title: "OpenAI API-Key", infoKey: "apiKey", info: "Dein OpenAI API-Schlüssel, beginnt mit 'sk-'") {
                    VStack(spacing: 16) {
                        if !apiKey.isEmpty {
                            HStack {
                                Text("API-Key ist konfiguriert")
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        apiKey = ""
                                        newAPIKey = ""
                                    }
                                } label: {
                                    Text("Entfernen")
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            Text("Kein API-Key vorhanden")
                                .foregroundColor(.red)
                        }
                        
                        TextField("Neuer API-Key", text: $newAPIKey)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button {
                            if newAPIKey.starts(with: "sk-") {
                                apiKey = newAPIKey
                                newAPIKey = ""
                                fetchModels()
                            } else {
                                showingAlert = true
                            }
                        } label: {
                            Text("Speichern")
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .disabled(newAPIKey.isEmpty)
                        .opacity(newAPIKey.isEmpty ? 0.5 : 1)
                    }
                    .padding(.vertical, 8)
                }
                
                settingBlock(title: "Organisation-ID", infoKey: "orgID", info: "Deine OpenAI Organisation (optional).") {
                    TextField("org-...", text: $openAIOrgID)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
                
                settingBlock(title: "Verfügbare Modelle", infoKey: "models", info: "Liste der verfügbaren OpenAI-Modelle mit deinem API-Key.") {
                    if apiKey.isEmpty {
                        Text("Kein API-Key konfiguriert")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else if availableModels.isEmpty {
                        ProgressView("Lade Modelle...")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(availableModels.prefix(5), id: \.self) { model in
                                Text("• \(model)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, design: .monospaced))
                            }
                            
                            if availableModels.count > 5 {
                                Text("+ \(availableModels.count - 5) weitere...")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, design: .monospaced))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // MARK: - API Info
                settingBlock(title: "Information", infoKey: "apiInfo", info: "Wichtige Informationen zur API") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Der API-Key wird sicher in deinem Gerät gespeichert und nicht weitergegeben.")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        
                        Text("Um einen API-Key zu erhalten, besuche die OpenAI-Website und erstelle einen unter deinem Account.")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        
                        Link("OpenAI API-Dokumentation", destination: URL(string: "https://platform.openai.com/docs/api-reference")!)
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .alert("Ungültiger API-Key", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Der API-Key sollte mit 'sk-' beginnen. Bitte überprüfe deinen Schlüssel.")
        }
        .onAppear {
            if !apiKey.isEmpty {
                fetchModels()
            }
        }
    }
    
    @ViewBuilder
    private func settingBlock<Content: View>(title: String, infoKey: String, info: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(title).foregroundColor(.white)
                Button {
                    showingInfo[infoKey] = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .popover(isPresented: Binding(get: {
                    showingInfo[infoKey] ?? false
                }, set: {
                    showingInfo[infoKey] = $0
                })) {
                    Text(info)
                        .font(.system(size: 14, design: .monospaced))
                        .padding()
                        .frame(width: 250)
                }
            }
            content()
        }
    }
    
    private func fetchModels() {
        apiManager.fetchAvailableModels(apiKey: apiKey) { models in
            self.availableModels = models.isEmpty ? fallbackModels : models
        }
    }
}
