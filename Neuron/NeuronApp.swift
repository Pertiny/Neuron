import SwiftUI

@main
struct NeuronApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .preferredColorScheme(.dark)
        }
    }
}
