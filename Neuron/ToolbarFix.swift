import SwiftUI

struct ToolbarFix: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func fixedToolbarStyle() -> some View {
        self.modifier(ToolbarFix())
    }
}