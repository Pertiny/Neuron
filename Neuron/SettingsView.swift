import SwiftUI

// MARK: - SettingsView mit eigenem "<" Back-Button

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("apiKey") private var storedAPIKey: String = ""
    
    @State private var tempAPIKey: String = ""
    @State private var showAlert = false
    
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("language") private var language: String = "Deutsch"
    private let languages = ["Deutsch", "English", "Français", "Español"]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Form {
                Section(header: Text("API-Einstellungen")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API-Key")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        
                        TextField("Trage hier deinen OpenAI-Key ein", text: $tempAPIKey)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onAppear {
                                tempAPIKey = storedAPIKey
                            }
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            if tempAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showAlert = true
                            } else {
                                storedAPIKey = tempAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
                                dismiss()
                            }
                        }) {
                            Text("Speichern")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(tempAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Button(role: .destructive, action: {
                            tempAPIKey = ""
                            storedAPIKey = ""
                        }) {
                            Text("Löschen")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .listRowBackground(Color.black)
                
                Section(header: Text("Erscheinungsbild")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)) {
                    Picker("Modus", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.white)
                }
                .listRowBackground(Color.black)
                
                Section(header: Text("Sprache")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)) {
                    Picker("Sprache", selection: $language) {
                        ForEach(languages, id: \.self) { lang in
                            Text(lang).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                }
                .listRowBackground(Color.black)
                
                Section(header: Text("Infos")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)) {
                    NavigationLink(destination: ComingSoonView(title: "Impressum")) {
                        Text("Impressum")
                    }
                    NavigationLink(destination: ComingSoonView(title: "Datenschutz")) {
                        Text("Datenschutz")
                    }
                    NavigationLink(destination: ComingSoonView(title: "Version")) {
                        Text("Version")
                    }
                }
                .listRowBackground(Color.black)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .preferredColorScheme(appearanceMode.colorScheme)
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // nativen Back-Button ausblenden
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("<")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                }
            }
            .alert("API-Key fehlt", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Bitte gib einen gültigen API-Key ein, um die App nutzen zu können.")
            }
        }
    }
}

enum AppearanceMode: String, CaseIterable {
    case light = "Hell"
    case dark = "Dunkel"
    case system = "System"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - ComingSoonView mit eigenem Back-Button

struct ComingSoonView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("\(title) – Coming Soon")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(true) // nativen Back-Button ausblenden
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("<")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
            }
        }
    }
}
