//
//  HDApp.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI
import SwiftData
import UserNotifications
internal import CoreData

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}

// MARK: - Main App

@main
struct HDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var appState = AppState()
    @State private var showingSplash = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Hike.self,
            HikeType.self,
            LAWRoute.self,
            PhotoMedia.self,
            AudioMedia.self,
            UserData.self,
        ])
        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase =
            FileManager.default.ubiquityIdentityToken != nil ? .automatic : .none

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKitDatabase
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed default data
            seedDefaultData(context: container.mainContext)

            // Remove any duplicates created by seed + iCloud overlap
            deduplicateHikeTypes(context: container.mainContext)

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// Removes duplicate HikeTypes by name, keeping the one with the lowest sortOrder.
    static func deduplicateHikeTypes(context: ModelContext) {
        guard let allTypes = try? context.fetch(FetchDescriptor<HikeType>()) else { return }

        let grouped = Dictionary(grouping: allTypes) { $0.name }
        var didDelete = false

        for (_, types) in grouped where types.count > 1 {
            let sorted = types.sorted { $0.sortOrder < $1.sortOrder }
            for duplicate in sorted.dropFirst() {
                context.delete(duplicate)
                didDelete = true
            }
        }

        if didDelete {
            try? context.save()
        }
    }

    private static func seedDefaultData(context: ModelContext) {
        let defaultTypes: [(name: String, iconName: String, sortOrder: Int)] = [
            ("Boswandeling", "tree", 0),
            ("LAW-route", "signpost.right", 1),
            ("Blokje om", "arrow.triangle.turn.up.right.circle", 2),
            ("Stadswandeling", "building.2", 3),
            ("Klompenpad", "shoe.2", 4),
            ("Strandwandeling", "beach.umbrella", 5),
            ("Dagwandeling", "sun.max", 6),
            ("Bergwandeling", "mountain.2", 7),
        ]

        // Fetch existing types to avoid duplicates (handles iCloud sync scenarios)
        let existingTypes = (try? context.fetch(FetchDescriptor<HikeType>())) ?? []
        let existingNames = Set(existingTypes.map { $0.name })

        for type in defaultTypes {
            if !existingNames.contains(type.name) {
                context.insert(HikeType(name: type.name, iconName: type.iconName, sortOrder: type.sortOrder))
            }
        }

        try? context.save()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showingSplash && appState.isOnboarded {
                    SplashView {
                        withAnimation {
                            showingSplash = false
                        }
                    }
                } else if appState.isOnboarded {
                    NavigationStack(path: $appState.navigationPath) {
                        HikesOverviewView()
                    }
                    .environment(appState)
                } else {
                    OnboardingContainerView()
                        .environment(appState)
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    appState.updateLastAppOpened()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
                HDApp.deduplicateHikeTypes(context: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
