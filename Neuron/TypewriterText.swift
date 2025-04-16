import SwiftUI

struct TypewriterText: View {
    let fullText: String
    @State private var displayedText: String = ""
    var speed: Double = 0.015

    var body: some View {
        Text(displayedText)
            .onAppear {
                displayedText = ""
                var currentIndex = 0
                Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
                    if currentIndex < fullText.count {
                        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                        displayedText.append(fullText[index])
                        currentIndex += 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
    }
}