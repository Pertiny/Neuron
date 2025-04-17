import SwiftUI

@main
struct NeuronApp: App {
    @StateObject private var navigationModel = NavigationModel()
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationModel.path) {
                MainMenuView()
                    .navigationDestination(for: NeuronDestination.self) { destination in
                        switch destination {
                        case .chat(let session):
                            ChatView(loadedSession: session)
                        case .history:
                            HistoryView()
                        case .settings:
                            SettingsContainerView(initialTab: 0)
                        case .chatSettings:
                            SettingsContainerView(initialTab: 1)
                        case .apiSettings:
                            SettingsContainerView(initialTab: 2)
                        }
                    }
            }
            .sheet(item: $navigationModel.presentedSheet) { destination in
                switch destination {
                case .chat(let session):
                    ChatView(loadedSession: session)
                case .history:
                    HistoryView()
                case .settings:
                    SettingsContainerView(initialTab: 0)
                case .chatSettings:
                    SettingsContainerView(initialTab: 1)
                case .apiSettings:
                    SettingsContainerView(initialTab: 2)
                }
            }
            .environmentObject(navigationModel)
            .preferredColorScheme(.dark)
        }
    }
}
