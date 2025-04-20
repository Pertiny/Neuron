//
//  NewChatView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

struct NewChatView: View {
    @StateObject private var viewModel = NewChatViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isPromptFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                promptHeader
                
                promptList
                
                divider
                
                customPromptInput
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    modelSelector
                }
            }
            .modifier(ThemeModifier())
            .onAppear {
                // Automatisch Fokus auf Eingabefeld setzen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPromptFocused = true
                }
            }
        }
    }
    
    private var promptHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start with a prompt or use a template")
                .font(themeManager.currentTheme.bodyFont)
                .padding(.horizontal)
            
            Text("Selected model: \(viewModel.selectedModel.name)")
                .font(themeManager.currentTheme.captionFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
    
    private var promptList: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Mögliche Prompt-Vorlagen
                ForEach(viewModel.promptTemplates) { template in
                    Button {
                        viewModel.selectTemplate(template)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.title)
                                .font(themeManager.currentTheme.bodyFont.bold())
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                            
                            Text(template.description)
                                .font(themeManager.currentTheme.captionFont)
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                                .lineLimit(2)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.currentTheme.background.opacity(0.7))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.currentTheme.textSecondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(themeManager.currentTheme.textSecondary.opacity(0.2))
            .frame(height: 1)
            .padding(.vertical, 8)
    }
    
    private var customPromptInput: some View {
        VStack(spacing: 12) {
            TextField("Type your custom prompt...", text: $viewModel.userInput)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.currentTheme.background.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.textSecondary.opacity(0.2), lineWidth: 1)
                )
                .focused($isPromptFocused)
            
            Button {
                createChat()
            } label: {
                Text("Start Chat")
                    .font(themeManager.currentTheme.bodyFont.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentTheme.accent)
                    )
            }
            .disabled(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
        }
        .padding()
    }
    
    private var modelSelector: some View {
        Menu {
            ForEach(ChatModel.availableModels, id: \.id) { model in
                Button {
                    viewModel.selectedModel = model
                } label: {
                    HStack {
                        Text(model.name)
                        if model.id == viewModel.selectedModel.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text("Model")
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
        }
    }
    
    private func createChat() {
        guard !viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Chat erstellen
        let chatId = viewModel.createNewChat()
        
        // Haptisches Feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Modal schließen
        dismiss()
        
        // Zur Chat-Detailansicht navigieren
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            coordinator.navigate(to: .chatDetail(id: chatId))
        }
    }
}

// ViewModel für New Chat
final class NewChatViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var selectedModel: ChatModel = ChatModel.availableModels[0]
    
    // Prompt-Vorlagen
    struct PromptTemplate: Identifiable {
        var id = UUID()
        var title: String
        var description: String
        var promptText: String
    }
    
    let promptTemplates: [PromptTemplate] = [
        PromptTemplate(
            title: "General Discussion",
            description: "Start a conversation about any topic",
            promptText: "I'd like to discuss something with you."
        ),
        PromptTemplate(
            title: "Creative Writing",
            description: "Get help with creative writing projects",
            promptText: "I need help with a creative writing project. Can you assist me?"
        ),
        PromptTemplate(
            title: "Technical Explanation",
            description: "Get a detailed explanation of a technical concept",
            promptText: "Can you explain the following technical concept to me?"
        ),
        PromptTemplate(
            title: "Problem Solving",
            description: "Get help solving a specific problem",
            promptText: "I'm facing the following problem and need help solving it:"
        ),
        PromptTemplate(
            title: "Code Review",
            description: "Get feedback on your code",
            promptText: "Can you review the following code and suggest improvements?\n\n```\n\n```"
        )
    ]
    
    func selectTemplate(_ template: PromptTemplate) {
        userInput = template.promptText
    }
    
    func createNewChat() -> UUID {
        let chatId = UUID()
        let userMessage = Message(role: .user, content: userInput)
        
        let newChat = Chat(
            id: chatId,
            title: "New Chat",
            messages: [userMessage],
            modelId: selectedModel.id
        )
        
        do {
            try ChatStorageService.shared.saveChat(newChat)
        } catch {
            print("Failed to create new chat: \(error)")
        }
        
        return chatId
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
            .environmentObject(ThemeManager())
            .environmentObject(AppCoordinator())
    }
}
