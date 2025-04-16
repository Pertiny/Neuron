import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("openAIOrgID") private var openAIOrgID: String = ""
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("language") private var language: String = "Deutsch"

    @State private var tempAPIKey: String = ""
    @State private var showAlert = false

    private let languages = ["Deutsch", "English", "Français", "Español"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Form {
                // API
                Section(header: sectionTitle("API")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API-Key").foregroundColor(.white)

                        TextField("sk-...", text: $tempAPIKey)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .onAppear {
                                tempAPIKey = apiKey
                            }

                        Text("Organisation-ID (optional)")
                            .foregroundColor(.white)
                            .padding(.top, 8)

                        TextField("org-...", text: $openAIOrgID)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    HStack(spacing: 16) {
                        Button("Speichern") {
                            let trimmed = tempAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
                            if trimmed.isEmpty {
                                showAlert = true
                            } else {
                                apiKey = trimmed
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(tempAPIKey.trimmingCharacters(in: .whitespaces).isEmpty)

                        Button("Löschen", role: .destructive) {
                            apiKey = ""
                            tempAPIKey = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .listRowBackground(Color.black)

                // Appearance
                Section(header: sectionTitle("Erscheinungsbild")) {
                    Picker("Modus", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.white)
                }
                .listRowBackground(Color.black)

                // Sprache
                Section(header: sectionTitle("Sprache")) {
                    Picker("Sprache", selection: $language) {
                        ForEach(languages, id: \.self) { lang in
                            Text(lang).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                }
                .listRowBackground(Color.black)

                // Infos
                Section(header: sectionTitle("Infos")) {
                    NavigationLink("Impressum") { ComingSoonView(title: "Impressum") }
                    NavigationLink("Datenschutz") { ComingSoonView(title: "Datenschutz") }
                    NavigationLink("Version") { ComingSoonView(title: "Version") }
                }
                .listRowBackground(Color.black)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("<") { dismiss() }
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            .alert("API-Key fehlt", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Bitte gib einen gültigen API-Key ein, um die App nutzen zu können.")
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
    }
}