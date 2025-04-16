import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    let userTextColor: Color
    @Binding var animatedMessageIDs: Set<UUID>

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                TextBlockView(message: message, userColor: userTextColor)
                    .multilineTextAlignment(.trailing)
            } else {
                TextBlockView(
                    message: message,
                    userColor: userTextColor,
                    isAnimated: !animatedMessageIDs.contains(message.id)
                )
                .onAppear {
                    animatedMessageIDs.insert(message.id)
                }
                Spacer()
            }
        }
    }
}
