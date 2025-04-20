import SwiftUI
import UIKit

@_implementationOnly import Neuron

struct ChatInputView: View {
    @Binding var input: String
    var isFocused: FocusState<Bool>.Binding
    let isLoading: Bool
    let onSend: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Erweiterter Textbereich
            ZStack(alignment: .topLeading) {
                TextEditor(text: $input)
                    .padding(10)
                    .background(themeManager.currentTheme.background.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.currentTheme.textSecondary.opacity(0.3), lineWidth: 1)
                    )
                    .frame(minHeight: 40, maxHeight: 120)
                    .focused(isFocused) // <-- korrigiert: übergebene Binding verwenden
                
                // Placeholder-Text
                if input.isEmpty {
                    Text("Type your message...")
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.top, 16)
                }
            }
            .font(themeManager.currentTheme.bodyFont)

            // Sende-Button
            Button(action: {
                onSend()
                
                // Cursor am Ende positionieren
                let newPosition = input.endIndex
                DispatchQueue.main.async {
                    input = String(input[..<newPosition])
                }
            }) {
                ZStack {
                    Circle()
                        .fill(themeManager.currentTheme.accent)
                        .frame(width: 44, height: 44)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(isLoading || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .animation(.spring(), value: isLoading)
            .padding(.bottom, 5)
        }
        .padding(8)
        .onChange(of: input) { _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.1)
        }
    }
}

struct ChatInputView_Previews: PreviewProvider {
    @FocusState static var previewFocus: Bool

    static var previews: some View {
        VStack {
            ChatInputView(
                input: .constant("Hello world"),
                isFocused: $previewFocus, // korrekt: Binding wird übergeben
                isLoading: false,
                onSend: {}
            )

            ChatInputView(
                input: .constant(""),
                isFocused: $previewFocus,
                isLoading: true,
                onSend: {}
            )
        }
        .padding()
        .environmentObject(ThemeManager())
    }
}
