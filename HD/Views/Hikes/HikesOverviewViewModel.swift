import Foundation
import SwiftData

@Observable
final class HikesOverviewViewModel {
    var searchText = ""
    var sortOption: SortOption = .dateNewest
    var selectedTypes: Set<String> = []

    enum SortOption: String, CaseIterable {
        case dateNewest = "Datum (nieuw → oud)"
        case dateOldest = "Datum (oud → nieuw)"
        case nameAZ = "A-Z"
    }

    func filteredAndSortedHikes(from hikes: [Hike]) -> [Hike] {
        var result = hikes

        // Filter op type
        if !selectedTypes.isEmpty {
            result = result.filter { selectedTypes.contains($0.type) }
        }

        // Zoeken
        if !searchText.isEmpty {
            result = result.filter { hike in
                hike.name.localizedCaseInsensitiveContains(searchText) ||
                hike.type.localizedCaseInsensitiveContains(searchText) ||
                hike.companions.localizedCaseInsensitiveContains(searchText) ||
                (hike.startLocationName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (hike.endLocationName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                hike.story.localizedCaseInsensitiveContains(searchText) ||
                hike.notes.localizedCaseInsensitiveContains(searchText) ||
                hike.terrainDescription.localizedCaseInsensitiveContains(searchText) ||
                hike.weatherDescription.localizedCaseInsensitiveContains(searchText) ||
                hike.reflection.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sorteren
        switch sortOption {
        case .dateNewest:
            result.sort { $0.startTime > $1.startTime }
        case .dateOldest:
            result.sort { $0.startTime < $1.startTime }
        case .nameAZ:
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }

        return result
    }

    func availableTypes(from hikes: [Hike]) -> [String] {
        let types = Set(hikes.map { $0.type })
        return Array(types).sorted()
    }
}
