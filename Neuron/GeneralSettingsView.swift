import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @AppStorage("autoSaveSessions") private var autoSaveSessions: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Theme Settings
                SettingsSection(title: "Erscheinungsbild") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeOptionRow(
                            theme: theme,
                            isSelected: selectedTheme == theme,
                            onSelect: { selectedTheme = theme }
                        )
                    }
                }
                
                // MARK: - Interface Settings
                SettingsSection(title: "Interface") {
                    ToggleRow(
                        title: "Haptisches Feedback",
                        description: "Vibrationseffekte bei Interaktionen",
                        isOn: $hapticFeedback
                    )
                    
                    ToggleRow(
                        title: "Sessions automatisch speichern",
                        description: "Chats werden nach jeder Nachricht gespeichert",
                        isOn: $autoSaveSessions
                    )
                }
                
                // MARK: - About App
                SettingsSection(title: "Über Neuron") {
                    InfoRow(title: "Version", value: "1.0.0")
                    InfoRow(title: "Build", value: "102")
                    
                    Button {
                        // Feedback-Email
                    } label: {
                        HStack {
                            Text("Feedback senden")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
}

