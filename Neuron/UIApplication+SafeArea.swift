import UIKit

extension UIApplication {
    var firstSafeAreaTop: CGFloat {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 0
    }

    var firstSafeAreaBottom: CGFloat {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom }
            .first ?? 0
    }
}
