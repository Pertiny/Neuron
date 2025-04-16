import SwiftUI

@main
struct NeuronApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LaunchRouterView()
            }
            .fixedToolbarStyle() // ⬅️ globaler Toolbar-Stil
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .preferredColorScheme(.dark)
        }
    }
}
