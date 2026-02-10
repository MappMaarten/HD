import SwiftUI
import UIKit
import Combine

@MainActor
final class KeyboardObserver: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    @Published var animationDuration: Double = 0.25

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to keyboard show notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> (CGFloat, Double)? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                    return nil
                }
                return (keyboardFrame.height, duration)
            }
            .sink { [weak self] (height, duration) in
                guard let self = self else { return }
                self.animationDuration = duration
                withAnimation(.easeOut(duration: duration)) {
                    self.currentHeight = height
                }
            }
            .store(in: &cancellables)

        // Subscribe to keyboard hide notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { notification -> Double? in
                notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            }
            .sink { [weak self] duration in
                guard let self = self else { return }
                self.animationDuration = duration
                withAnimation(.easeOut(duration: duration)) {
                    self.currentHeight = 0
                }
            }
            .store(in: &cancellables)
    }
}
