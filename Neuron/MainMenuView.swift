import SwiftUI

struct MainMenuView: View {
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic

    @State private var showNewChat = false
    @State private var showHistory = false
    @State private var showSettings = false
    @StateObject private var network = NetworkMonitor.shared

    var body: some View {
        let currentTheme = selectedTheme

        ZStack(alignment: .top) {
            currentTheme.backgroundColor.edgesIgnoringSafeArea(.all)

            // 🔔 Verbindung prüfen
            ConnectionBannerView(isConnected: network.isConnected)

            VStack(spacing: 40) {
                Spacer().frame(height: network.isConnected ? 0 : 40)

                Text("Neuron")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(currentTheme.primaryText)

                VStack(spacing: 20) {
                    Button(action: { showNewChat = true }) {
                        Text("Neuer Chat")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(currentTheme.buttonText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(currentTheme.buttonBackground)
                            .cornerRadius(12)
                    }

                    Button(action: { showHistory = true }) {
                        Text("Verlauf")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(currentTheme.secondaryText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentTheme.secondaryText.opacity(0.4), lineWidth: 1)
                            )
                    }

                    Button(action: { showSettings = true }) {
                        Text("Einstellungen")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(currentTheme.secondaryText)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showNewChat) {
            ChatView()
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            GeneralSettingsView()
        }
    }
}
