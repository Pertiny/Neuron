//
//  TerminalButton.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

struct TerminalButton: View {
    let title: String
    let action: () -> Void
    let role: ButtonRole?
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.isEnabled) private var isEnabled
    
    init(
        _ title: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role, action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .font(themeManager.currentTheme.hasTerminalEffect ? .system(.body, design: .monospaced) : .body)
                .foregroundColor(buttonTextColor)
                .background(buttonBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: isTerminal ? 4 : 8)
                        .strokeBorder(buttonBorderColor, lineWidth: isTerminal ? 1 : 0)
                )
                .cornerRadius(isTerminal ? 4 : 8)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isEnabled ? 1 : 0.6)
    }
    
    private var isTerminal: Bool {
        themeManager.currentTheme.hasTerminalEffect
    }
    
    private var buttonTextColor: Color {
        if let role = role, role == .destructive {
            return themeManager.currentTheme.hasTerminalEffect ? .red : .white
        } else {
            return themeManager.currentTheme.hasTerminalEffect ? themeManager.currentTheme.textPrimary : .white
        }
    }
    
    private var buttonBackground: Color {
        if themeManager.currentTheme.hasTerminalEffect {
            return .clear
        } else {
            if let role = role, role == .destructive {
                return .red
            } else {
                return themeManager.currentTheme.accent
            }
        }
    }
    
    private var buttonBorderColor: Color {
        if let role = role, role == .destructive {
            return .red
        } else {
            return themeManager.currentTheme.textPrimary
        }
    }
}

// MARK: - Variationen

extension TerminalButton {
    // Sekundärer Button (weniger hervorgehoben)
    static func secondary(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        SecondaryTerminalButton(title: title, action: action)
    }
    
    // Icon-Button
    static func icon(
        systemName: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        IconTerminalButton(systemName: systemName, role: role, action: action)
    }
}

struct SecondaryTerminalButton: View {
    let title: String
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .font(themeManager.currentTheme.hasTerminalEffect ? .system(.body, design: .monospaced) : .body)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: themeManager.currentTheme.hasTerminalEffect ? 4 : 8)
                        .strokeBorder(themeManager.currentTheme.textSecondary, lineWidth: 1)
                )
                .cornerRadius(themeManager.currentTheme.hasTerminalEffect ? 4 : 8)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isEnabled ? 1 : 0.6)
    }
}

struct IconTerminalButton: View {
    let systemName: String
    let role: ButtonRole?
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        Button(role: role, action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16))
                .padding(10)
                .foregroundColor(
                    getButtonColor()
                )
                .background(
                    themeManager.currentTheme.hasTerminalEffect ? 
                        Color.clear : 
                        getButtonColor().opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: themeManager.currentTheme.hasTerminalEffect ? 4 : 8)
                        .strokeBorder(
                            themeManager.currentTheme.hasTerminalEffect ? getButtonColor() : Color.clear, 
                            lineWidth: 1
                        )
                )
                .cornerRadius(themeManager.currentTheme.hasTerminalEffect ? 4 : 8)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isEnabled ? 1 : 0.6)
    }
    
    private func getButtonColor() -> Color {
        if let role = role, role == .destructive {
            return .red
        } else {
            return themeManager.currentTheme.accent
        }
    }
}

// MARK: - Previews

struct TerminalButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TerminalButton("Primary Button") {
                print("Primary tapped")
            }
            
            TerminalButton("Destructive Button", role: .destructive) {
                print("Destructive tapped")
            }
            .disabled(true)
            
            TerminalButton.secondary("Secondary Button") {
                print("Secondary tapped")
            }
            
            HStack {
                TerminalButton.icon(systemName: "plus") {
                    print("Plus tapped")
                }
                
                TerminalButton.icon(systemName: "trash", role: .destructive) {
                    print("Trash tapped")
                }
            }
        }
        .padding()
        .environmentObject(ThemeManager())
        .previewLayout(.sizeThatFits)
    }
}
