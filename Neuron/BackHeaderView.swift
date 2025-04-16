import SwiftUI

struct BackHeaderView: View {
    var title: String = ""
    var onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Text("<")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            Spacer()
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            // Platzhalter, damit der Titel zentriert bleibt
            Text(" ")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .opacity(0)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(Color.black)
    }
}