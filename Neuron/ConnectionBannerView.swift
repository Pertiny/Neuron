import SwiftUI

struct ConnectionBannerView: View {
    let isConnected: Bool

    var body: some View {
        VStack {
            if !isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("Keine Internetverbindung")
                        .foregroundColor(.white)
                        .font(.system(size: 14, design: .monospaced))
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.9))
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: isConnected)
    }
}