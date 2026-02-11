import SwiftUI

struct KeyboardAdaptive: ViewModifier {
    @StateObject private var keyboardObserver = KeyboardObserver()
    var tabBarHeight: CGFloat = 70

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: keyboardObserver.currentHeight > 0
                        ? max(0, keyboardObserver.currentHeight - tabBarHeight)
                        : 0)
            }
    }
}

extension View {
    func keyboardAdaptive(tabBarHeight: CGFloat = 70) -> some View {
        modifier(KeyboardAdaptive(tabBarHeight: tabBarHeight))
    }
}
