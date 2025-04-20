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
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Verbesserte Suchleiste
                searchBarView
                
                // Filter für Chat-Typen
                filterView
                
                Divider()
                    .background(themeManager.currentTheme.textSecondary.opacity(0.3))
                
                // Chat-Liste oder andere Zustände
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredChats.isEmpty {
                    emptyStateView
                } else {
                    chatListView
                }
            }
            .navigationTitle("Neuron")
            .toolbar {
                toolbarItems
            }
            .environment(\.editMode, $editMode)
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
        }
    }
    
    // MARK: - Subviews
    
    // Verbesserte Suchleiste
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .padding(.leading, 8)
            
            TextField("Search Chats", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(themeManager.currentTheme.bodyFont)
                .foregroundColor(themeManager.currentTheme.textPrimary)
                .onChange(of: searchText) { newValue in
                    viewModel.filterChats(searchQuery: newValue)
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
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // Filter-Chips
    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChatFilterOption.allCases) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: viewModel.currentFilter == filter,
                        onTap: {
                            withAnimation {
                                viewModel.currentFilter = filter
                                viewModel.filterChats() // Trigger filter refresh
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    // Verbesserte Liste mit Sektionen
    private var chatListView: some View {
        List {
            // Angeheftete Chats in eigener Sektion
            if !viewModel.pinnedChats.isEmpty {
                Section("Pinned") {
                    ForEach(viewModel.pinnedChats) { chat in
                        EnhancedChatRow(chat: chat) {
                            coordinator.navigate(to: .chatDetail(id: chat.id))
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.togglePinChat(chat)
                            } label: {
                                Label("Unpin", systemImage: "pin.slash")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                chatToDelete = chat.id
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            contextMenuItems(for: chat)
                        }
                    }
                }
                .listSectionSeparator(.hidden)
            }
            
            // Nicht angeheftete Chats
            Section(viewModel.pinnedChats.isEmpty ? "" : "Chats") {
                ForEach(viewModel.unpinnedChats) { chat in
                    EnhancedChatRow(chat: chat) {
                        coordinator.navigate(to: .chatDetail(id: chat.id))
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.togglePinChat(chat)
                        } label: {
                            Label("Pin", systemImage: "pin")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            chatToDelete = chat.id
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        contextMenuItems(for: chat)
                    }
                }
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: viewModel.filteredChats)
        .refreshable {
            viewModel.loadChats()
        }
    }
    
    // Ladeanimation
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.accent))
            Text("Loading Chats...")
                .font(themeManager.currentTheme.captionFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Kombinierter Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 70))
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            Text(searchText.isEmpty ? "No Chats Yet" : "No matching chats")
                .font(themeManager.currentTheme.titleFont)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text(searchText.isEmpty ?
                 "Start a new conversation by creating your first chat" :
                 "Try a different search term")
                .font(themeManager.currentTheme.bodyFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if searchText.isEmpty {
                Button {
                    coordinator.presentSheet(.newChat)
                } label: {
                    Text("Create New Chat")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.accent)
                        .foregroundColor(.white)
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
    
    // Toolbar mit Edit-Button
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    coordinator.presentSheet(.settings)
                } label: {
                    Image(systemName: "gear")
                        .foregroundColor(themeManager.currentTheme.accent)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(themeManager.currentTheme.accent)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    coordinator.presentSheet(.newChat)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(themeManager.currentTheme.accent)
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
            
            Button(role: .destructive) {
                chatToDelete = chat.id
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Benutzeroberflächen-Komponenten

// Filter-Chip für Chat-Kategorien
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(themeManager.currentTheme.captionFont)
                .foregroundColor(isSelected ? .white : themeManager.currentTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? themeManager.currentTheme.accent : Color.gray.opacity(0.2))
                )
        }
    }
}

// Verbesserte Chat-Zeile mit Avatar
struct EnhancedChatRow: View {
    let chat: Chat
    let onTap: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Chat-Icon
                ZStack {
                    Circle()
                        .fill(themeManager.currentTheme.accent.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Text(chat.title.prefix(1).uppercased())
                        .font(themeManager.currentTheme.bodyFont.bold())
                        .foregroundColor(themeManager.currentTheme.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
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
                            .font(.caption2)
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                    
                    // Nachrichtenvorschau
                    Text(chat.lastMessagePreview)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .lineLimit(2)
                        .padding(.trailing, 4)
                    
                    // Modellinformation und Nachrichtenzähler
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
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
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
