import SwiftUI
import MarkdownUI

struct ChatBubbleView: View {
    let message: ChatMessage

    var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
            if isUser {
                Text(message.content)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Markdown(message.content)
                        .markdownTextStyle {
                            Font(.system(size: 14, design: .monospaced))
                        }
                        .foregroundColor(.white)

                    Button(action: {
                        UIPasteboard.general.string = message.content
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            Text("Kopieren")
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
    }
}