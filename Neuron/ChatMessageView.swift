struct ChatMessageView: View {
    let message: ChatMessage
    let userTextColor: Color
    @Binding var animatedMessageIDs: Set<UUID>

    var body: some View {
        if message.role == .assistant && !animatedMessageIDs.contains(message.id) {
            TypingTextView(text: message.content)
                .onAppear {
                    animatedMessageIDs.insert(message.id)
                }
        } else {
            TextBlockView(
                message: message,
                userColor: userTextColor
            )
        }
    }
}