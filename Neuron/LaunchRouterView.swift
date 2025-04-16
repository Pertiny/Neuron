import SwiftUI

struct LaunchRouterView: View {
    @AppStorage("apiKey") private var apiKey: String = ""

    var body: some View {
        Group {
            if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                StartView()
            } else {
                MainMenuView()
            }
        }
    }
}