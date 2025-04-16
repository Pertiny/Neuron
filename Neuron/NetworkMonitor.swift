import Foundation
import Network
import SwiftUI
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                print(self.isConnected ? "📶 Online" : "🚫 Kein Netzwerk")
            }
        }
        monitor.start(queue: queue)
    }
}