import SwiftUI

struct ChatSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Aktuelle Settings
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("openAIOrgID") private var openAIOrgID: String = ""
    @AppStorage("chatModel") private var chatModel: String = "gpt-3.5-turbo"
    @AppStorage("chatMaxTokens") private var chatMaxTokens: Int = 512
    @AppStorage("chatTemperature") private var chatTemperature: Double = 0.7
    @AppStorage("chatTopP") private var chatTopP: Double = 1.0
    @AppStorage("chatPresencePenalty") private var chatPresencePenalty: Double = 0.0
    @AppStorage("chatFrequencyPenalty") private var chatFrequencyPenalty: Double = 0.0
    @AppStorage("chatInitialPrompt") private var chatInitialPrompt: String = "You are a helpful assistant."
    @AppStorage("userTextColorHex") private var userTextColorHex: String = "#00FFCC"

    @State private var availableModels: [String] = []
    @StateObject private var apiManager = APIManager()

    @State private var showTemplateSheet = false
    @State private var savedTemplates: [ChatTemplate] = []
    @State private var newTemplateName: String = ""

    private let fallbackModels = [
        "gpt-3.5-turbo", "gpt-3.5-turbo-16k",
        "gpt-4", "gpt-4-32k", "gpt-4-0613", "gpt-4-turbo", "gpt-4o"
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackHeaderView(title: "Chat Settings") {
                    dismiss()
                }
                Spacer()
                Button {
                    showTemplateSheet = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.white)
                        .padding(.trailing, 16)
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Modellwahl
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Modell")
                            .foregroundColor(.white)
                        if availableModels.isEmpty {
                            ProgressView("Lade Modelle ...").foregroundColor(.white)
                        } else {
                            Picker("Modell wählen", selection: $chatModel) {
                                ForEach(availableModels, id: \.self) {
                                    Text($0).tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(.white)
                        }
                    }

                    // Org-ID
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Organisation-ID")
                            .foregroundColor(.white)
                        TextField("org-...", text: $openAIOrgID)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }

                    // Schieberegler
                    sliderInt(title: "Max Tokens", value: $chatMaxTokens, range: 100...4096, step: 100)
                    sliderDouble(title: "Temperature", value: $chatTemperature, range: 0...1, step: 0.01)
                    sliderDouble(title: "Top P", value: $chatTopP, range: 0...1, step: 0.05)
                    sliderDouble(title: "Presence Penalty", value: $chatPresencePenalty, range: 0...2, step: 0.1)
                    sliderDouble(title: "Frequency Penalty", value: $chatFrequencyPenalty, range: 0...2, step: 0.1)

                    // System-Prompt
                    VStack(alignment: .leading, spacing: 8) {
                        Text("System Prompt")
                            .foregroundColor(.white)
                        TextEditor(text: $chatInitialPrompt)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                            .frame(minHeight: 100)
                    }

                    // Farbe
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Farbe deiner Nachrichten")
                            .foregroundColor(.white)
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: userTextColorHex) },
                            set: { userTextColorHex = $0.hexString }
                        ))
                        .labelsHidden()
                        .frame(height: 32)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .onAppear {
            fetchModels()
            loadTemplates()
        }
        .sheet(isPresented: $showTemplateSheet) {
            templateSheet
        }
    }

    // MARK: - Template Sheet
    private var templateSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Template Name", text: $newTemplateName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                    .foregroundColor(.white)

                Button("Aktuelle Einstellungen speichern") {
                    let new = ChatTemplate(
                        title: newTemplateName,
                        model: chatModel,
                        maxTokens: chatMaxTokens,
                        temperature: chatTemperature,
                        topP: chatTopP,
                        presencePenalty: chatPresencePenalty,
                        frequencyPenalty: chatFrequencyPenalty,
                        initialPrompt: chatInitialPrompt
                    )
                    savedTemplates.append(new)
                    saveTemplates()
                    showTemplateSheet = false
                }

                Divider().background(Color.white)

                List {
                    ForEach(savedTemplates) { template in
                        Button(template.title) {
                            applyTemplate(template)
                            showTemplateSheet = false
                        }
                    }
                    .onDelete { indexSet in
                        savedTemplates.remove(atOffsets: indexSet)
                        saveTemplates()
                    }
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        showTemplateSheet = false
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Slider Helpers

    private func sliderDouble(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title): \(String(format: "%.2f", value.wrappedValue))")
                .foregroundColor(.white)
            NoThumbSlider(value: value, range: range, step: step)
                .frame(height: 16)
        }
    }

    private func sliderInt(title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title): \(value.wrappedValue)")
                .foregroundColor(.white)

            NoThumbSlider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Int(round($0 / Double(step)) * Double(step)) }
                ),
                range: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step)
            )
            .frame(height: 16)
        }
    }

    // MARK: - Template Handling

    private func applyTemplate(_ template: ChatTemplate) {
        chatModel = template.model
        chatMaxTokens = template.maxTokens
        chatTemperature = template.temperature
        chatTopP = template.topP
        chatPresencePenalty = template.presencePenalty
        chatFrequencyPenalty = template.frequencyPenalty
        chatInitialPrompt = template.initialPrompt
    }

    private func saveTemplates() {
        if let data = try? JSONEncoder().encode(savedTemplates) {
            UserDefaults.standard.set(data, forKey: "chatTemplates")
        }
    }

    private func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: "chatTemplates"),
           let decoded = try? JSONDecoder().decode([ChatTemplate].self, from: data) {
            self.savedTemplates = decoded
        }
    }

    private func fetchModels() {
        apiManager.fetchAvailableModels(apiKey: apiKey) { models in
            self.availableModels = models.isEmpty ? fallbackModels : models
            if !availableModels.contains(chatModel) {
                chatModel = availableModels.first ?? "gpt-3.5-turbo"
            }
        }
    }
}
