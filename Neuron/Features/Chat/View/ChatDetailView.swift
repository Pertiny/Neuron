//
//  ChatDetailView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//

import SwiftUI

struct ChatDetailView: View {
    @StateObject var viewModel: ChatDetailViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingEditTitleAlert = false
    @State private var newTitle = ""
    @State private var showingDeleteConfirm = false
    @State private var showingClearConfirm = false
    @FocusState private var isInputFocused: Bool
    
    init(chatId: UUID) {
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatId: chatId))
    }
    
    var body: some View {
        content
            .navigationTitle(viewModel.chat?.title ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    titleView
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    actionMenu
                }
            }
            .alert("Rename Chat", isPresented: $showingEditTitleAlert) {
                TextField("Chat title", text: $newTitle)
                
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    viewModel.updateTitle(newTitle)
                }
            }
            .alert("Clear all messages?", isPresented: $showingClearConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    viewModel.clearChat()
                }
            }
            .alert("Delete this chat?", isPresented: $showingDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteChat()
                    coordinator.goBack()
                }
            }
            .alert(isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.loadChat()
            }
            .onDisappear {
                // Speichere beim Verlassen
                if let chat = viewModel.chat {
                    do {
                        try ChatStorageService.shared.saveChat(chat)
                    } catch {
                        print("Failed to save chat: \(error)")
                    }
                }
            }
    }
    
    // Hauptcontent als eigene Computed Property
    private var content: some View {
        VStack(spacing: 0) {
            messagesView
            
            Divider()
                .background(themeManager.currentTheme.textSecondary)
            
            inputSection
        }
    }
    
    // Titel als eigene View
    private var titleView: some View {
        Text(viewModel.chat?.title ?? "Chat")
            .font(themeManager.currentTheme.titleFont)
            .foregroundColor(themeManager.currentTheme.textPrimary)
            .onTapGesture {
                newTitle = viewModel.chat?.title ?? ""
                showingEditTitleAlert = true
            }
    }
    
    // Action-Menü als eigene View
    private var actionMenu: some View {
        Menu {
            Button {
                newTitle = viewModel.chat?.title ?? ""
                showingEditTitleAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Button {
                viewModel.togglePinChat()
            } label: {
                Label(
                    viewModel.chat?.isPinned == true ? "Unpin" : "Pin",
                    systemImage: viewModel.chat?.isPinned == true ? "pin.slash" : "pin"
                )
            }
            
            Button {
                coordinator.navigate(to: .modelSelection)
            } label: {
                Label("Change Model", systemImage: "cpu")
            }
            
            Divider()
            
            Button(role: .destructive) {
                showingClearConfirm = true
            } label: {
                Label("Clear Chat", systemImage: "trash")
            }
            
            Button(role: .destructive) {
                showingDeleteConfirm = true
            } label: {
                Label("Delete Chat", systemImage: "trash.fill")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    // Input-Bereich als eigene View
    private var inputSection: some View {
        VStack(spacing: 4) {
            // Token-Counter anzeigen
            TokenCounterView(
                currentTokens: viewModel.tokenCount,
                maxTokens: viewModel.selectedModel.maxTokens,
                percent: viewModel.percentOfMaxTokens
            )
            
            // Input-Bereich - Korrigierte FocusState-Übergabe
            ChatInputView(
                input: $viewModel.userInput,
                isFocused: $isInputFocused,  // Hier Binding mit $ statt _
                isLoading: viewModel.isLoading,
                onSend: viewModel.sendMessage
            )
        }
        .padding(.horizontal)
        .padding(.bottom, viewModel.keyboardHeight > 0 ? 0 : 8)
    }

    
    // Nachrichtenbereich als eigene Computed Property
    private var messagesView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                chatContent(scrollView: scrollView)
                    .padding(.horizontal)
                    .padding(.top)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.chat?.messages.count) { _ in
                scrollToLastMessage(in: scrollView)
            }
            .onChange(of: viewModel.isLoading) { isLoading in
                scrollToLoadingIndicator(isLoading: isLoading, in: scrollView)
            }
        }
    }
    
    // Trennung der Chat-Inhalte zur besseren Lesbarkeit
    @ViewBuilder
    private func chatContent(scrollView: ScrollViewProxy) -> some View {
        LazyVStack(spacing: 12) {
            if let chat = viewModel.chat, !chat.messages.isEmpty {
                // Nachrichten anzeigen
                ForEach(chat.messages) { message in
                    MessageBubbleView(message: message)
                        .id(message.id)
                }
                
                // Ladeanzeige für wartende Antworten
                if viewModel.isLoading {
                    TypingIndicator()
                        .id("loadingIndicator")
                }
            } else {
                // Erster Start / Leerer Chat
                EmptyChatView(modelName: viewModel.selectedModel.name) {
                    isInputFocused = true
                }
            }
        }
    }
    
    // Hilfsmethode zum Scrollen
    private func scrollToLastMessage(in scrollView: ScrollViewProxy) {
        withAnimation {
            if let lastMessage = viewModel.chat?.messages.last {
                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    // Hilfsmethode zum Scrollen zur Ladeanzeige
    private func scrollToLoadingIndicator(isLoading: Bool, in scrollView: ScrollViewProxy) {
        if isLoading {
            withAnimation {
                scrollView.scrollTo("loadingIndicator", anchor: .bottom)
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 6, height: 6)
                .offset(y: sin(animationOffset) * 2)
            
            Circle()
                .frame(width: 6, height: 6)
                .offset(y: sin(animationOffset + 1) * 2)
            
            Circle()
                .frame(width: 6, height: 6)
                .offset(y: sin(animationOffset + 2) * 2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationOffset = 2 * .pi
            }
        }
    }
}

struct EmptyChatView: View {
    let modelName: String
    let onStartChat: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 70))
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            Text("Start a conversation")
                .font(themeManager.currentTheme.titleFont)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text("Send a message to begin chatting with \(modelName)")
                .font(themeManager.currentTheme.bodyFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                onStartChat()
            } label: {
                Text("Type a message")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.currentTheme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = AppCoordinator()
        let themeManager = ThemeManager()
        
        ChatDetailView(chatId: Chat.mockChats[0].id)
            .environmentObject(coordinator)
            .environmentObject(themeManager)
    }
}
