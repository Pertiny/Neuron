import SwiftUI

struct TypewriterText: View {
    let fullText: String
    let typingSpeed: Double
    let textColor: Color
    let font: Font

    @State private var displayedText: String = ""
    @State private var timer: Timer?

    var body: some View {
        Text(displayedText)
            .foregroundColor(textColor)
            .font(font)
            .onAppear {
                startTyping()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }

    private func startTyping() {
        displayedText = ""
        var index = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { t in
            if index < fullText.count {
                let nextChar = fullText[fullText.index(fullText.startIndex, offsetBy: index)]
                displayedText.append(nextChar)
                index += 1
            } else {
                t.invalidate()
            }
        }
    }
}
