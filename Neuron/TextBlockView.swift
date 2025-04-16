import SwiftUI

struct TextBlockView: View {
    let message: ChatMessage
    let userColor: Color

    var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        Text(message.content)
            .font(.system(size: 14, design: .monospaced))
            .foregroundColor(isUser ? userColor : .white)
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .contextMenu {
                Button("Kopieren") {
                    UIPasteboard.general.string = message.content
                }
            }
    }
}