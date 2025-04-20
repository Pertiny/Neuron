//
//  MessageBubbleView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isCopied = false
    @State private var showingFullText = false
    
    private var isUserMessage: Bool {
        message.role == .user
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Absender-Label
            HStack(spacing: 4) {
                Image(systemName: message.role.iconName)
                    .font(.caption)
                
                Text(message.role.displayName)
                    .font(themeManager.currentTheme.captionFont.bold())
                
                Spacer()
                
                Text(formatDate(message.timestamp))
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                    .opacity(0.7)
            }
            .foregroundColor(isUserMessage
                             ? themeManager.currentTheme.accent
                             : themeManager.currentTheme.secondary)
            .padding(.horizontal, 12)
            
            // Nachrichteninhalt
            MessageContentView(content: message.content)
                .padding(12)
                .background(isUserMessage
                            ? themeManager.currentTheme.accent.opacity(0.1)
                            : (colorScheme == .dark
                               ? Color.gray.opacity(0.15)
                               : Color.gray.opacity(0.1)))
                .cornerRadius(12)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = message.content
                        isCopied = true
                        
                        // Zeitgesteuert Feedback zurücksetzen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isCopied = false
                        }
                        
                        // Haptisches Feedback
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        showingFullText = true
                    } label: {
                        Label("Show Full Text", systemImage: "text.magnifyingglass")
                    }
                }
        }
        .padding(.horizontal, 4)
        .overlay(alignment: .topTrailing) {
            if isCopied {
                Text("Copied!")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.green)
                    .cornerRadius(4)
                    .transition(.opacity)
            }
        }
        .animation(.easeIn(duration: 0.2), value: isCopied)
        .frame(maxWidth: .infinity, alignment: isUserMessage ? .trailing : .leading)
        .sheet(isPresented: $showingFullText) {
            MessageFullTextView(message: message)
        }
        .conditionalTerminalEffect(isEnabled: themeManager.currentTheme.hasTerminalEffect && message.role == .assistant)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageContentView: View {
    let content: String
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        if content.contains("```") {
            // Markdown-Code-Block-Handling
            CodeBlockFormattedText(content: content)
        } else {
            // Normaler Text mit Markdown-Support
            Text(LocalizedStringKey(content))
                .font(themeManager.currentTheme.bodyFont)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CodeBlockFormattedText: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let parts = splitContentByCodeBlocks(content)
            
            ForEach(parts.indices, id: \.self) { index in
                let part = parts[index]
                
                if part.isCodeBlock {
                    CodeBlockView(code: part.text, language: part.language)
                } else {
                    Text(LocalizedStringKey(part.text))
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    struct ContentPart {
        var text: String
        var isCodeBlock: Bool
        var language: String
    }
    
    func splitContentByCodeBlocks(_ content: String) -> [ContentPart] {
        let pattern = "```([a-zA-Z]*)\\r?\\n?([\\s\\S]*?)```"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var parts: [ContentPart] = []
        var lastEndIndex = 0
        
        for match in matches {
            // Text vor dem Code-Block
            let preRange = NSRange(location: lastEndIndex, length: match.range.location - lastEndIndex)
            if preRange.length > 0 {
                let preText = nsString.substring(with: preRange)
                if !preText.isEmpty {
                    parts.append(ContentPart(text: preText, isCodeBlock: false, language: ""))
                }
            }
            
            // Sprache und Code-Inhalt extrahieren
            let languageRange = Range(match.range(at: 1), in: content)
            let codeRange = Range(match.range(at: 2), in: content)
            
            let language = languageRange.map { String(content[$0]) } ?? ""
            let code = codeRange.map { String(content[$0]) } ?? ""
            
            if !code.isEmpty {
                parts.append(ContentPart(text: code, isCodeBlock: true, language: language))
            }
            
            lastEndIndex = match.range.upperBound
        }
        
        // Text nach dem letzten Code-Block
        if lastEndIndex < nsString.length {
            let trailingText = nsString.substring(from: lastEndIndex)
            if !trailingText.isEmpty {
                parts.append(ContentPart(text: trailingText, isCodeBlock: false, language: ""))
            }
        }
        
        return parts
    }
}

struct CodeBlockView: View {
    let code: String
    let language: String
    
    @State private var isCopied = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header mit Sprache und Kopier-Button
            HStack {
                if !language.isEmpty {
                    Text(language)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 4)
                }
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = code
                    withAnimation {
                        isCopied = true
                    }
                    
                    // Zeitgesteuert Feedback zurücksetzen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isCopied = false
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.clipboard")
                            .font(.caption)
                        
                        Text(isCopied ? "Copied!" : "Copy")
                            .font(.caption)
                    }
                    .padding(6)
                    .background(isCopied ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(4)
                }
            }
            
            // Code-Inhalt
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(2)
            }
        }
        .padding(8)
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct MessageFullTextView: View {
    let message: Message
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: message.role.iconName)
                            .font(.title2)
                        
                        Text(message.role.displayName)
                            .font(themeManager.currentTheme.titleFont)
                        
                        Spacer()
                        
                        Text(formatDate(message.timestamp))
                            .font(themeManager.currentTheme.captionFont)
                    }
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .padding(.bottom)
                    
                    MessageContentView(content: message.content)
                }
                .padding()
                .textSelection(.enabled)
            }
            .navigationBarTitle("Message", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIPasteboard.general.string = message.content
                        // Haptisches Feedback
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageBubbleView(
                message: Message(
                    role: .user,
                    content: "Hello! I have a question about quantum computing."
                )
            )
            
            MessageBubbleView(
                message: Message(
                    role: .assistant,
                    content: "Sure, I'd be happy to help with quantum computing. What would you like to know?\n\nHere's a code example:\n\n```python\ndef quantum_example():\n    # This is just a simple example\n    print('Quantum computing is fascinating!')\n```\n\nAnd some more text after the code block."
                )
            )
        }
        .padding()
        .environmentObject(ThemeManager())
    }
}
