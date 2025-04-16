import SwiftUI

struct MainMenuView: View {
    @State private var showNewChat = false
    @State private var showHistory = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text("Neuron")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                VStack(spacing: 20) {
                    Button(action: {
                        showNewChat = true
                    }) {
                        Text("Neuer Chat")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        showHistory = true
                    }) {
                        Text("Verlauf")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }

                    Button(action: {
                        showSettings = true
                    }) {
                        Text("Einstellungen")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showNewChat) {
            ChatView() // oder deine passende Chat-Start-View
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView() // oder AllChatsView
        }
        .fullScreenCover(isPresented: $showSettings) {
            ChatSettingsView()
        }
    }
}