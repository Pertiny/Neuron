import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("apiKey") private var storedAPIKey: String = ""
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("language") private var language: String = "Deutsch"
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic

    @State private var tempAPIKey: String = ""
    @State private var showAlert = false

    private let languages = ["Deutsch", "English", "Français", "Español"]

    var body: some View {
        let currentTheme = selectedTheme

        ZStack {
            currentTheme.backgroundColor.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("<")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(currentTheme.primaryText)
                        }
                        Spacer()
                        Text("Einstellungen")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(currentTheme.primaryText)
                        Spacer().frame(width: 24)
                    }
                    .padding(.horizontal)

                    // MARK: API-Key
                    VStack(alignment: .leading, spacing: 12) {
                        Text("API-Key")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        TextField("Trage hier deinen OpenAI-Key ein", text: $tempAPIKey)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .onAppear {
                                tempAPIKey = storedAPIKey
                            }

                        HStack {
                            Button("Speichern") {
                                if tempAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    showAlert = true
                                } else {
                                    storedAPIKey = tempAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
                                    dismiss()
                                }
                            }
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)

                            Button("Löschen", role: .destructive) {
                                tempAPIKey = ""
                                storedAPIKey = ""
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                        }
                        .font(.system(size: 14, design: .monospaced))
                    }
                    .padding(.horizontal)

                    // MARK: Erscheinungsbild
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Erscheinungsbild")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        Picker("Modus", selection: $appearanceMode) {
                            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(currentTheme.accentColor)
                    }
                    .padding(.horizontal)

                    // MARK: Theme
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        Picker("Theme", selection: $selectedTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(currentTheme.accentColor)
                    }
                    .padding(.horizontal)

                    // MARK: Sprache
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sprache")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        Picker("Sprache", selection: $language) {
                            ForEach(languages, id: \.self) { lang in
                                Text(lang).tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(currentTheme.accentColor)
                    }
                    .padding(.horizontal)

                    // MARK: Infos
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Infos")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        NavigationLink(destination: ComingSoonView(title: "Impressum")) {
                            Text("Impressum")
                        }
                        NavigationLink(destination: ComingSoonView(title: "Datenschutz")) {
                            Text("Datenschutz")
                        }
                        NavigationLink(destination: ComingSoonView(title: "Version")) {
                            Text("Version")
                        }
                        NavigationLink(destination: KeyDebugView()) {
                            Text("API-Key Debug")
                        }
                    }
                    .padding(.horizontal)
                    .foregroundColor(currentTheme.secondaryText)
                    .font(.system(size: 14, design: .monospaced))

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
        .alert("API-Key fehlt", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Bitte gib einen gültigen API-Key ein.")
        }
    }
}
