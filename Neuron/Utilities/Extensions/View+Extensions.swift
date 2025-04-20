import SwiftUI

// MARK: - View Modifiers & Extensions
extension View {
    /// Bedingte Anwendung eines Modifiers
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Fügt der View eine Hintergrund mit Opacity hinzu
    func withBackground(
        color: Color,
        opacity: Double = 0.1,
        cornerRadius: CGFloat = 8
    ) -> some View {
        self.padding()
            .background(color.opacity(opacity))
            .cornerRadius(cornerRadius)
    }
    
    /// Terminal-Effekt für Button/Controls
    func terminalStyle() -> some View {
        self.modifier(TerminalButtonModifier())
    }
    
    /// Übliche Stilgebung für Cards
    func cardStyle(isSelected: Bool = false) -> some View {
        modifier(CardStyleModifier(isSelected: isSelected))
    }
    
    /// Eine Erweiterung, um einfachere Rahmen zu erstellen
    func outlineBorder(
        color: Color,
        width: CGFloat = 1,
        cornerRadius: CGFloat = 8
    ) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: width)
        )
    }
    
    /// Versteckt/zeigt eine View basierend auf einer Bedingung
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if remove {
                return AnyView(EmptyView())
            } else {
                return AnyView(self.hidden())
            }
        } else {
            return AnyView(self)
        }
    }
    
    /// Einfache Erweiterung, um Padding auf allen Seiten anzuwenden
    func paddingAll(_ amount: CGFloat) -> some View {
        self.padding(.all, amount)
    }
    
    /// Erweiterung zum Hinzufügen eines Tap-Feedback-Effekts
    func withTapFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    /// Erweiterung für einfachere ResponsiveLayout-Anpassungen
    func responsiveFrame(idealWidth: CGFloat, maxWidth: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        self.frame(idealWidth: idealWidth, maxWidth: maxWidth, alignment: alignment)
    }
    
    /// Modal-Kontext schneller schließen
    func withCloseButton(dismiss: DismissAction) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

// MARK: - Custom Modifiers

/// Modifier für Terminal-Buttons
struct TerminalButtonModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isEnabled ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                isEnabled ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary,
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

/// Modifier für Card-Design
struct CardStyleModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.background)
                    .shadow(
                        color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? themeManager.currentTheme.accent : .clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
    }
}

// MARK: - Convenience Extensions

extension Color {
    /// Erzeugt eine leicht abgedunkelte Variante für Hervorhebungen
    func darkened(by amount: CGFloat = 0.1) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount)
        )
    }
    
    /// Erzeugt eine leicht aufgehellte Variante für Hervorhebungen
    func lightened(by amount: CGFloat = 0.1) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount)
        )
    }
}

// MARK: - View Helpers

/// Leere View zur Platzhalternutzung
struct EmptyStateView: View {
    var systemImage: String
    var title: String
    var message: String
    var buttonText: String?
    var action: (() -> Void)?
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 70))
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            Text(title)
                .font(themeManager.currentTheme.titleFont)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text(message)
                .font(themeManager.currentTheme.bodyFont)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let buttonText = buttonText, let action = action {
                Button(action: action) {
                    Text(buttonText)
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
    }
}

/// Einheitliche Progress-Erweiterung
struct CustomProgressView: View {
    var title: String?
    var showBackground: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            
            if let title = title {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .if(showBackground) { view in
            view
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(radius: 1)
        }
    }
}

// MARK: - Preview Helper

/// Test-Daten Erweiterung für Previews
extension PreviewProvider {
    static var mockThemeManager: ThemeManager {
        let manager = ThemeManager()
        return manager
    }
    
    static var mockCoordinator: AppCoordinator {
        return AppCoordinator()
    }
}
