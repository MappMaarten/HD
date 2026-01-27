import Foundation
import SwiftUI

@Observable
final class AppState {
    // MARK: - Onboarding
    var isOnboarded: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isOnboarded")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isOnboarded")
        }
    }

    // MARK: - App Lifecycle
    var lastAppOpenedTimestamp: Date? {
        get {
            let timestamp = UserDefaults.standard.double(forKey: "lastAppOpenedTimestamp")
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastAppOpenedTimestamp")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastAppOpenedTimestamp")
            }
        }
    }

    func shouldShowSplash() -> Bool {
        // Only apply time-based splash AFTER onboarding
        guard isOnboarded else { return false }

        guard let lastOpened = lastAppOpenedTimestamp else {
            // First time opening after onboarding completion
            return true
        }

        // 24 hours = 86400 seconds
        let splashThresholdSeconds: TimeInterval = 24 * 60 * 60
        let timeSinceLastOpen = Date().timeIntervalSince(lastOpened)

        return timeSinceLastOpen >= splashThresholdSeconds
    }

    func updateLastAppOpened() {
        lastAppOpenedTimestamp = Date()
    }

    // MARK: - Active Hike
    var activeHikeID: UUID? {
        didSet {
            if let id = activeHikeID {
                UserDefaults.standard.set(id.uuidString, forKey: "activeHikeID")
            } else {
                UserDefaults.standard.removeObject(forKey: "activeHikeID")
            }
        }
    }

    // MARK: - Navigation
    var navigationPath = NavigationPath()

    // MARK: - Sheets
    var showingNewHike = false
    var showingSettings = false

    init() {
        // Load persistent active hike ID
        if let idString = UserDefaults.standard.string(forKey: "activeHikeID"),
           let id = UUID(uuidString: idString) {
            activeHikeID = id
        }

        // Voor development kun je dit op false zetten om onboarding te testen
        // isOnboarded = false
    }

    func completeOnboarding() {
        isOnboarded = true
        updateLastAppOpened() // Mark as "just opened" so splash doesn't show immediately
    }
}
