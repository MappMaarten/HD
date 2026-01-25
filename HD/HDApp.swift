//
//  HDApp.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI
import SwiftData

@main
struct HDApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Hike.self,
            HikeType.self,
            LAWRoute.self,
            PhotoMedia.self,
            AudioMedia.self,
            UserData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed default data
            seedDefaultData(context: container.mainContext)

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    private static func seedDefaultData(context: ModelContext) {
        // Check if data already exists
        let hikeTypesCount = (try? context.fetchCount(FetchDescriptor<HikeType>())) ?? 0

        if hikeTypesCount == 0 {
            // Seed default hike types
            let defaultTypes = [
                HikeType(name: "Dagwandeling", iconName: "sun.max", sortOrder: 0),
                HikeType(name: "Meerdaagse wandeling", iconName: "calendar", sortOrder: 1),
                HikeType(name: "Stadswandeling", iconName: "building.2", sortOrder: 2),
                HikeType(name: "Boswandeling", iconName: "tree", sortOrder: 3),
                HikeType(name: "Bergwandeling", iconName: "mountain.2", sortOrder: 4),
                HikeType(name: "Strandwandeling", iconName: "beach.umbrella", sortOrder: 5),
                HikeType(name: "LAW-route", iconName: "signpost.right", sortOrder: 6)
            ]

            for type in defaultTypes {
                context.insert(type)
            }

            try? context.save()
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appState.navigationPath) {
                SplashView()  // Always show splash first
            }
            .environment(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
