//
//  ModelSelectionView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

struct ModelSelectionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedModel: ChatModel? = nil
    
    // ViewModel der Chat-Detail-Ansicht (für Aktualisierungen)
    @ObservedObject var chatViewModel: ChatDetailViewModel
    
    init(chatViewModel: ChatDetailViewModel) {
        self.chatViewModel = chatViewModel
        self._selectedModel = State(initialValue: ChatModel.getModel(for: chatViewModel.chat?.modelId ?? ""))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                
                modelSectionView(title: "Standard Models", category: .standard)
                
                modelSectionView(title: "Premium Models", category: .premium)
            }
            .padding()
        }
        .navigationTitle("Select Model")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    coordinator.goBack()
                } label: {
                    Text("Done")
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Select AI Model")
                .font(themeManager.currentTheme.titleFont)
                .foregroundColor(themeManager.currentTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Different models have different capabilities and pricing")
                .font(themeManager.currentTheme.bodyFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom)
    }
    
    private func modelSectionView(title: String, category: ChatModel.Category) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(themeManager.currentTheme.bodyFont.bold())
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            ForEach(ChatModel.availableModels.filter { $0.category == category }) { model in
                modelCard(model: model)
            }
        }
    }
    
    private func modelCard(model: ChatModel) -> some View {
        let isSelected = selectedModel?.id == model.id
        
        return Button {
            selectedModel = model
            chatViewModel.changeModel(to: model.id)
            
            // Haptisches Feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(model.name)
                            .font(themeManager.currentTheme.bodyFont.bold())
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(themeManager.currentTheme.accent)
                        }
                    }
                    
                    Text(model.description)
                        .font(themeManager.currentTheme.captionFont)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    modelSpecsView(model: model)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? themeManager.currentTheme.accent.opacity(0.1) : themeManager.currentTheme.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? themeManager.currentTheme.accent : themeManager.currentTheme.textSecondary.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func modelSpecsView(model: ChatModel) -> some View {
        HStack {
            modelSpecItem(
                title: "Max Tokens",
                value: formatNumber(model.maxTokens),
                systemImage: "textformat.size"
            )
            
            Spacer()
            
            modelSpecItem(
                title: "Cost Per 1K",
                value: "$\(String(format: "%.4f", model.costPer1KTokens))",
                systemImage: "dollarsign.circle"
            )
            
            if model.supportsVision {
                Spacer()
                
                modelSpecItem(
                    title: "Vision",
                    value: "Supported",
                    systemImage: "eye"
                )
            }
        }
    }
    
    private func modelSpecItem(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption2)
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
            }
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            let formatted = Double(number) / 1_000_000.0
            return String(format: "%.1fM", formatted)
        } else if number >= 1_000 {
            let formatted = Double(number) / 1_000.0
            return String(format: "%.1fK", formatted)
        } else {
            return "\(number)"
        }
    }
}

// Wrapper für NavigationStack-Integration
struct ModelSelectionWrapper: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    let chatId: UUID
    
    var body: some View {
        if let chatVM = getChatViewModel() {
            ModelSelectionView(chatViewModel: chatVM)
        } else {
            Text("Error loading chat")
                .onAppear {
                    coordinator.goBack()
                }
        }
    }
    
    private func getChatViewModel() -> ChatDetailViewModel? {
        return ChatDetailViewModel(chatId: chatId)
    }
}

struct ModelSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let chatViewModel = ChatDetailViewModel(chatId: Chat.mockChats[0].id)
        
        NavigationView {
            ModelSelectionView(chatViewModel: chatViewModel)
                .environmentObject(AppCoordinator())
                .environmentObject(ThemeManager())
        }
    }
}
