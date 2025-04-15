import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let chat: ChatSession
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(chat.messages.indices, id: \.self) { i in
                        let msg = chat.messages[i]
                        Text(msg.content)
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(msg.role == "user"
                                             ? Color(red: 127/255, green: 255/255, blue: 212/255)
                                             : .white)
                            .frame(maxWidth: .infinity,
                                   alignment: msg.role == "user" ? .trailing : .leading)
                            .padding(.horizontal, 12)
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Text("<")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(chat.title)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
            }
        }
        .preferredColorScheme(.dark)
    }
}
