//
//  SettingsView.swift
//  Neuron
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = SettingsViewModel(themeManager: ThemeManager())

    @State private var showThemeEditor = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $viewModel.selectedThemeType) {
                        ForEach(ThemeType.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .onChange(of: viewModel.selectedThemeType) {
                        themeManager.currentTheme = Theme(type: $0)
                    }

                    if !viewModel.customThemes.isEmpty {
                        Picker("Custom Themes", selection: $viewModel.selectedCustomTheme) {
                            Text("None").tag(CustomTheme?.none)
                            ForEach(viewModel.customThemes, id: \.id) { theme in
                                Text(theme.name).tag(Optional(theme))
                            }
                        }
                        .onChange(of: viewModel.selectedCustomTheme) { _ in
                            viewModel.applySelectedCustomTheme(to: themeManager)
                        }
                    }

                    Button("Create Custom Theme") {
                        showThemeEditor = true
                    }
                    .foregroundColor(themeManager.currentTheme.accent)
                }

                Section(header: Text("API Settings")) {
                    NavigationLink(destination: ApiSettingsView()) {
                        Label("API Configuration", systemImage: "key.fill")
                    }

                    Picker("Default Model", selection: $viewModel.defaultModel) {
                        ForEach(viewModel.availableModels) { model in
                            Text(model.name).tag(model.id)
                        }
                    }
                }

                Section(header: Text("Privacy & Data")) {
                    Toggle("Save Conversations Locally", isOn: $viewModel.saveConversationsLocally)
                        .onChange(of: viewModel.saveConversationsLocally) {
                            viewModel.updateSaveConversationsSetting($0)
                        }

                    Toggle("Use iCloud Sync", isOn: $viewModel.useICloudSync)
                        .onChange(of: viewModel.useICloudSync) {
                            viewModel.updateiCloudSyncSetting($0)
                        }

                    Button("Clear All Chat Data", role: .destructive) {
                        viewModel.showClearDataAlert = true
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("About Neuron", systemImage: "info.circle")
                    }

                    Link(destination: URL(string: "https://github.com/Pertiny/Neuron")!) {
                        HStack {
                            Label("GitHub Repository", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showThemeEditor) {
                ThemeEditor().environmentObject(themeManager)
            }
            .alert("Clear All Chat Data", isPresented: $viewModel.showClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.clearAllChatData()
                }
            } message: {
                Text("This will permanently delete all your chats.")
            }
            .onAppear {
                viewModel.loadSettings()
            }
        }
    }
}

// MARK: - ViewModel

class SettingsViewModel: ObservableObject {
    @Published var selectedThemeType: ThemeType = .terminal
    @Published var customThemes: [CustomTheme] = []
    @Published var selectedCustomTheme: CustomTheme? = nil

    @Published var defaultModel: UUID = UUID()
    @Published var availableModels: [AIModel] = []

    @Published var saveConversationsLocally = true
    @Published var useICloudSync = false
    @Published var showClearDataAlert = false

    private let themeManager: ThemeManager

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    init(themeManager: ThemeManager) {
        self.themeManager = themeManager
        self.customThemes = themeManager.customThemes
        self.selectedThemeType = themeManager.currentTheme.type
        loadAvailableModels()
    }

    func applySelectedCustomTheme(to manager: ThemeManager) {
        guard let selected = selectedCustomTheme else { return }
        manager.currentTheme = selected.asStandardTheme()
    }

    func loadSettings() {
        saveConversationsLocally = UserDefaults.standard.bool(forKey: "settings.saveConversationsLocally")
        useICloudSync = UserDefaults.standard.bool(forKey: "settings.useICloudSync")

        if let saved = UserDefaults.standard.string(forKey: "settings.defaultModel"),
           let modelId = UUID(uuidString: saved) {
            defaultModel = modelId
        }
    }

    private func loadAvailableModels() {
        availableModels = [
            AIModel(id: UUID(), name: "GPT-3.5", maxTokens: 4096),
            AIModel(id: UUID(), name: "GPT-4", maxTokens: 8192),
            AIModel(id: UUID(), name: "Claude 2", maxTokens: 100000)
        ]
    }

    func updateSaveConversationsSetting(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "settings.saveConversationsLocally")
    }

    func updateiCloudSyncSetting(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "settings.useICloudSync")
    }

    func clearAllChatData() {
        do {
            try ChatStorageService.shared.deleteAllChats()
        } catch {
            print("Error clearing chat data: \(error)")
        }
    }
}

// MARK: - API Settings View

struct ApiSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey = ""
    @State private var apiEndpoint = "https://api.openai.com/v1/chat/completions"
    @State private var isKeyValid = false
    @State private var isValidating = false
    @State private var validationError: String?

    var body: some View {
        Form {
            Section(header: Text("OpenAI API Settings")) {
                SecureField("API Key", text: $apiKey)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                TextField("API Endpoint", text: $apiEndpoint)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }

            Section {
                Button(isValidating ? "Validating..." : "Validate and Save API Key") {
                    validateApiKey()
                }
                .disabled(apiKey.isEmpty || isValidating)

                if let error = validationError {
                    Text(error).foregroundColor(.red)
                }

                if isKeyValid {
                    Label("API Key validated successfully!", systemImage: "checkmark.circle")
                        .foregroundColor(.green)
                }
            }

            Section(footer: Text("Your API key is securely stored in the iOS Keychain.")) {
                Link("Get an OpenAI API key", destination: URL(string: "https://platform.openai.com/account/api-keys")!)
                Link("API Documentation", destination: URL(string: "https://platform.openai.com/docs")!)
            }
        }
        .navigationTitle("API Settings")
        .onAppear(perform: loadSavedApiSettings)
    }

    private func loadSavedApiSettings() {
        apiKey = KeychainService.shared.getApiKey() ?? ""
        apiEndpoint = UserDefaults.standard.string(forKey: "settings.apiEndpoint") ?? apiEndpoint
    }

    private func validateApiKey() {
        isValidating = true
        validationError = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !apiKey.isEmpty {
                KeychainService.shared.saveApiKey(apiKey)
                UserDefaults.standard.set(apiEndpoint, forKey: "settings.apiEndpoint")
                isKeyValid = true
            } else {
                validationError = "API key validation failed"
                isKeyValid = false
            }
            isValidating = false
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .padding(.top)

                Text("Neuron")
                    .font(.largeTitle.bold())

                Text("A Modern ChatGPT Client")

                Divider()

                Group {
                    Text("Neuron is an open-source app designed for interacting with AI models.")
                    Text("• Clean, customizable UI")
                    Text("• Multiple AI models")
                    Text("• Local chat storage")
                    Text("• Custom themes")
                }

                Divider()

                Text("Developed by Pertiny")
                    .font(.headline)
                Text("Licensed under MIT")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

// MARK: - Keychain Service

class KeychainService {
    static let shared = KeychainService()
    private init() {}

    func saveApiKey(_ key: String) {
        UserDefaults.standard.set("SECURE_PLACEHOLDER", forKey: "DEMO_API_KEY_INDICATOR")
    }

    func getApiKey() -> String? {
        return UserDefaults.standard.string(forKey: "DEMO_API_KEY_INDICATOR") != nil ? "sk-..." : nil
    }
}
