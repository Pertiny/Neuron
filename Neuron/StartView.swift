import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    // Titel linksbündig
                    Text("Neuron")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Neuer Slogan mit Bezug zu Neuron und API
                    Text("MHHH")
                        .font(.system(size: 18, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(white: 0.7))
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Buttons modern und einheitlich
                    VStack(spacing: 16) {
                        NavigationButton(title: "New Chat", destination: ChatView())
                        NavigationButton(title: "History", destination: HistoryView())
                        NavigationButton(title: "Settings", destination: SettingsView())
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .frame(maxWidth: 600)
                .padding(.vertical, 40)
            }
            .navigationBarHidden(true)
        }
        .font(.system(size: 16, weight: .regular, design: .monospaced))
        .preferredColorScheme(.dark)
    }
}

struct NavigationButton<Destination: View>: View {
    let title: String
    let destination: Destination
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(isPressed ? 0.3 : 0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .preferredColorScheme(.dark)
    }
}
