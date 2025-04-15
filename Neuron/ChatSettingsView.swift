import SwiftUI

struct ChatSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("chatModel") private var chatModel: String = "gpt-3.5-turbo"
    @AppStorage("chatMaxTokens") private var chatMaxTokens: Int = 512
    @AppStorage("chatTemperature") private var chatTemperature: Double = 0.7
    @AppStorage("chatTopP") private var chatTopP: Double = 1.0
    @AppStorage("chatPresencePenalty") private var chatPresencePenalty: Double = 0.0
    @AppStorage("chatFrequencyPenalty") private var chatFrequencyPenalty: Double = 0.0
    @AppStorage("chatInitialPrompt") private var chatInitialPrompt: String = "You are a helpful assistant."
    
    private let availableModels = [
        "gpt-3.5-turbo",
        "gpt-3.5-turbo-16k",
        "gpt-4",
        "gpt-4-32k"
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Chat-Einstellungen")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Modell:")
                            .foregroundColor(.white)
                        Picker("Modell wählen", selection: $chatModel) {
                            ForEach(availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Max. Tokens: \(chatMaxTokens)")
                            .foregroundColor(.white)
                        Stepper("", value: $chatMaxTokens, in: 100...4096, step: 100)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        let tempDegrees = chatTemperature * 100
                        Text(String(format: "Temperature: %.0f°", tempDegrees))
                            .foregroundColor(.white)
                        NoThumbSlider(value: $chatTemperature, range: 0...1, step: 0.01)
                            .frame(height: 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(format: "Top P: %.2f", chatTopP))
                            .foregroundColor(.white)
                        NoThumbSlider(value: $chatTopP, range: 0...1, step: 0.05)
                            .frame(height: 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(format: "Presence Penalty: %.2f", chatPresencePenalty))
                            .foregroundColor(.white)
                        NoThumbSlider(value: $chatPresencePenalty, range: 0...2, step: 0.1)
                            .frame(height: 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(format: "Frequency Penalty: %.2f", chatFrequencyPenalty))
                            .foregroundColor(.white)
                        NoThumbSlider(value: $chatFrequencyPenalty, range: 0...2, step: 0.1)
                            .frame(height: 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("System Prompt:")
                            .foregroundColor(.white)
                        TextEditor(text: $chatInitialPrompt)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                            .frame(minHeight: 100)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
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
                Text("Chat Settings")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
            }
        }
        .font(.system(size: 16, weight: .regular, design: .monospaced))
        .preferredColorScheme(.dark)
    }
}

struct ChatSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatSettingsView()
        }
        .preferredColorScheme(.dark)
    }
}
