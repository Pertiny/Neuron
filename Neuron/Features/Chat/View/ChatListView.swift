//
//  ChatListView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var searchText = ""
    @State private var showingDeleteConfirmation = false
    @State private var chatToDelete: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Suchfeld
            searchBar
            
            // Hauptliste
            List {
                if viewModel.filteredChats.isEmpty {
                    emptyStateView
                } else {
                    chatListSection
                }
            }
            .listStyle(.plain)
            .animation(.easeInOut, value: viewModel.filteredChats)
            .refreshable {
                viewModel.loadChats()
            }
        }
        .navigationTitle("Chats")
        .toolbar {
            toolbarItems
        }
        .modifier(ThemeModifier())
        .onAppear {
            viewModel.loadChats()
        }
        .confirmationDialog(
            "Delete Chat",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = chatToDelete {
                    viewModel.deleteChat(id: id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            TextField("Search chats", text: $searchText)
                .font(themeManager.currentTheme.bodyFont)
                .onChange(of: searchText) { _ in
                    viewModel.filterChats(searchQuery: searchText)
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.filterChats(searchQuery: "")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }
        }
        .padding(10)
        .background(themeManager.currentTheme.background.opacity(0.8))
    }
    
    private var chatListSection: some View {
        ForEach(viewModel.filteredChats) { chat in
            ChatRowView(chat: chat)
                .contentShape(Rectangle())
                .onTapGesture {
                    coordinator.navigate(to: .chatDetail(id: chat.id))
                }
                .contextMenu {
                    contextMenuItems(for: chat)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        chatToDelete = chat.id
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        viewModel.togglePinChat(chat)
                    } label: {
                        Label(
                            chat.isPinned ? "Unpin" : "Pin",
                            systemImage: chat.isPinned ? "pin.slash" : "pin"
                        )
                    }
                    .tint(chat.isPinned ? .gray : .blue)
                }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            Text(searchText.isEmpty ? "No chats yet" : "No matching chats")
                .font(themeManager.currentTheme.titleFont)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text(searchText.isEmpty ? 
                 "Start a new conversation with the AI" : 
                 "Try a different search term")
                .font(themeManager.currentTheme.bodyFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button {
                    coordinator.presentSheet(.newChat)
                } label: {
                    Text("New Chat")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.accent)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    coordinator.presentSheet(.settings)
                } label: {
                    Image(systemName: "gear")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        coordinator.presentSheet(.newChat)
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func contextMenuItems(for chat: Chat) -> some View {
        Group {
            Button {
                viewModel.togglePinChat(chat)
            } label: {
                Label(
                    chat.isPinned ? "Unpin" : "Pin",
                    systemImage: chat.isPinned ? "pin.slash" : "pin"
                )
            }
            
            Button {
                chatToDelete = chat.id
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(chat.title)
                    .font(themeManager.currentTheme.bodyFont.bold())
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                if chat.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accent)
                }
                
                Text(formattedDate(chat.updatedAt))
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
            
            Text(chat.lastMessagePreview)
                .font(.system(size: 14)) // Gemäß Anforderung 14pt
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .lineLimit(2)
                .padding(.trailing, 4)
            
            HStack {
                Label(
                    ChatModel.getModel(for: chat.modelId).name,
                    systemImage: "cpu"
                )
                .font(themeManager.currentTheme.captionFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Spacer()
                
                Text("\(chat.messages.count) messages")
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = AppCoordinator()
        let themeManager = ThemeManager()
        
        NavigationView {
            ChatListView()
                .environmentObject(coordinator)
                .environmentObject(themeManager)
        }
    }
}
