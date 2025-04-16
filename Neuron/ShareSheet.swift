import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.excludedActivityTypes = [.assignToContact, .addToReadingList]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nichts zu aktualisieren
    }
}
