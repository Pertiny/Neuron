import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showChatSettings = false

    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("language") private var language: String = "Deutsch"
    private let languages = ["Deutsch", "English", "Français", "Español"]

    @State private var tempKey: String = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API-Key")) {
                    TextField("sk-...", text: $tempKey)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .onAppear { tempKey = apiKey }

                    HStack {
                        Button("Speichern") {
                            if tempKey.trimmingCharacters(in: .whitespaces).isEmpty {
                                showAlert = true
                            } else {
                                apiKey = tempKey.trimmingCharacters(in: .whitespaces)
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Löschen", role: .destructive) {
                            tempKey = ""
                            apiKey = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Section(header: Text("Erscheinungsbild")) {
                    Picker("Modus", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.white)
                }

                Section(header: Text("Sprache")) {
                    Picker("Sprache", selection: $language) {
                        ForEach(languages, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section {
                    Button("Chat-Einstellungen öffnen") {
                        showChatSettings = true
                    }
                }

                Section(header: Text("Debug & Info")) {
                    NavigationLink("API-Key Debug", destination: KeyDebugView())
                    NavigationLink("Impressum", destination: ComingSoonView(title: "Impressum"))
                    NavigationLink("Datenschutz", destination: ComingSoonView(title: "Datenschutz"))
                    NavigationLink("Version", destination: ComingSoonView(title: "Version"))
                }
            }
            .preferredColorScheme(appearanceMode.colorScheme)
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("<") { dismiss() }
                }
            }
            .alert("API-Key fehlt", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .fullScreenCover(isPresented: $showChatSettings) {
                ChatSettingsView()
            }
        }
    }
}
