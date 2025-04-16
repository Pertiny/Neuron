import SwiftUI

struct TextBlockView: View {
    let message: ChatMessage
    let userColor: Color
    var isAnimated: Bool = false

    @State private var visibleText = ""
    @State private var currentIndex = 0
    @State private var hasAnimated = false

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                Text(message.content)
                    .foregroundColor(userColor)
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 16)
            } else {
                Text(visibleText)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .onAppear {
                        if !hasAnimated {
                            animateTyping()
                            hasAnimated = true
                        } else {
                            visibleText = message.content
                        }
                    }
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = message.content
            }) {
                Label("Kopieren", systemImage: "doc.on.doc")
            }
        }
    }

    private func animateTyping() {
        visibleText = ""
        currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { timer in
            if currentIndex < message.content.count {
                let index = message.content.index(message.content.startIndex, offsetBy: currentIndex)
                visibleText.append(message.content[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
