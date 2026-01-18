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
    }
}
