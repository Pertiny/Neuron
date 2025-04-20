//
//  SettingsView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("chatgpt.apiKey") private var apiKey: String = ""
    @AppStorage("app.minWordCount") private var minWordCount: Int = 20
    
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingClearConfirm = false
    @State private var showingApiKeyInfo = false
    
    // State für die aktuelle Theme-Auswahl
    @State private var selectedThemeType: ThemeManager.ThemeType = .terminal
    
    var body: some View {
        NavigationView {
            Form {
                themeSection
                
                apiSection
                
                chatListSection
                
                clearDataSection
                
                aboutSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .modifier(ThemeModifier())
        .alert(isPresented: $showingClearConfirm) {
            Alert(
                title: Text("Clear All Chats"),
                message: Text("Are you sure you want to delete all chats? This cannot be undone."),
                primaryButton: .destructive(Text("Delete All")) {
                    clearAllChats()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            // Theme-Typ aus aktueller Theme auslesen, beim Erscheinen der View
            selectedThemeType = themeManager.currentTheme.type
        }
    }
    
    private var themeSection: some View {
        Section(header: Text("Appearance")) {
            Picker("Theme", selection: $selectedThemeType) {
                ForEach(ThemeManager.ThemeType.allCases) { themeType in
                    Text(themeType.displayName).tag(themeType)
                }
            }
            .onChange(of: selectedThemeType) { newValue in
                themeManager.switchTheme(to: newValue)
            }
        }
    }
    
    private var apiSection: some View {
        Section(header: apiSectionHeader) {
            SecureField("API Key", text: $apiKey)
                .font(.system(.body, design: .monospaced))
                .autocorrectionDisabled()
                .autocapitalization(.none)
            
            if themeManager.currentTheme.hasTerminalEffect {
                Toggle("CRT Scan Effect", isOn: .constant(true))
                    .foregroundColor(.gray)
                    .disabled(true)
            }
        }
    }
    
    private var apiSectionHeader: some View {
        HStack {
            Text("OpenAI API")
            
            Button {
                showingApiKeyInfo.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showingApiKeyInfo) {
                ApiKeyInfoView()
            }
        }
    }
    
    private var chatListSection: some View {
        Section(header: Text("Chat List")) {
            Stepper(
                "Minimum word count: \(minWordCount)",
                value: $minWordCount,
                in: 0...100,
                step: 5
            )
            
            Text("Chats with fewer words will be hidden from the list")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var clearDataSection: some View {
        Section {
            Button(role: .destructive) {
                showingClearConfirm = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All Chats")
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func clearAllChats() {
        do {
            try ChatStorageService.shared.deleteAllChats()
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            // Zurück zur Hauptansicht
            coordinator.popToRoot()
            dismiss()
        } catch {
            print("Failed to clear chats: \(error)")
        }
    }
}

struct ApiKeyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Get an OpenAI API Key")
                        .font(.title)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Visit the OpenAI website (openai.com) and sign up or log in")
                        Text("2. Navigate to the API section")
                        Text("3. Create a new API key")
                        Text("4. Copy the key and paste it in the settings")
                        Text("5. Your key will be stored securely on your device only")
                    }
                    .padding(.vertical)
                    
                    Text("Important Notes")
                        .font(.headline)
                    
                    Text("• The API key gives access to your OpenAI account and may incur costs\n• Never share your API key with others\n• You can set usage limits in your OpenAI account")
                    
                    Text("Visit the OpenAI website for more information about pricing and usage details.")
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("API Key Information")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
            .environmentObject(AppCoordinator())
    }
}
