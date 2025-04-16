import SwiftUI

struct LaunchRouterView: View {
    @AppStorage("apiKey") private var apiKey: String = ""

    @State private var showSplash = true
    @State private var fadeOutSplash = false

    var body: some View {
        ZStack {
            if showSplash {
                splashView
                    .opacity(fadeOutSplash ? 0 : 1)
                    .onAppear {
                        // Starte mit leichter Verzögerung für Effekt
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                fadeOutSplash = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                // Zielansicht
                if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    StartView()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    MainMenuView()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut, value: showSplash)
    }

    private var splashView: some View {
        VStack {
            Spacer()
            Text("Neuron")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
