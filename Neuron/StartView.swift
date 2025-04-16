import SwiftUI

struct StartView: View {
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("openAIOrgID") private var openAIOrgID: String = ""

    @State private var showMainMenu = false
    @State private var showSettings = false
    @State private var keyInvalid = false
    @State private var isValidating = false

    @StateObject private var apiManager = APIManager()
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Neuron")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Minimalistischer GPT-Client")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("API-Key")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(.gray)

                    SecureField("sk-...", text: $apiKey)
                        .font(.system(size: 14, design: .monospaced))
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    if keyInvalid {
                        Text("Ungültiger API-Key")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.red)
                    }

                    if apiKey.starts(with: "sk-proj-") && openAIOrgID.isEmpty {
                        Text("Organisation-ID erforderlich für Projekt-Keys")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.orange)
                    }

                    if !networkMonitor.isConnected {
                        Text("Keine Internetverbindung")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 16) {
                    Button(action: {
                        isValidating = true
                        apiManager.validateKey(apiKey) { isValid in
                            isValidating = false
                            if isValid {
                                keyInvalid = false
                                showMainMenu = true
                            } else {
                                keyInvalid = true
                            }
                        }
                    }) {
                        Text(isValidating ? "Prüfe..." : "Weiter")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                apiKey.isEmpty || isValidating || !networkMonitor.isConnected
                                ? Color.gray
                                : Color.white
                            )
                            .cornerRadius(12)
                    }
                    .disabled(apiKey.isEmpty || isValidating || !networkMonitor.isConnected)
                    .padding(.horizontal)

                    Button(action: {
                        showSettings = true
                    }) {
                        Text("Einstellungen")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showSettings) {
            GeneralSettingsView()
        }
        .fullScreenCover(isPresented: $showMainMenu) {
            MainMenuView()
        }
    }
}
