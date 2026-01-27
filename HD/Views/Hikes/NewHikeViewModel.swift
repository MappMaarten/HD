import Foundation

@Observable
final class NewHikeViewModel {
    var name: String = ""
    var selectedHikeType: HikeType?
    var companions: String = ""
    var startMood: Double = 5.0

    // Location fields
    var startLocationName: String = ""
    var startLatitude: Double?
    var startLongitude: Double?

    // LAW route fields
    var selectedLAWRoute: LAWRoute?
    var lawStageNumber: Int = 1

    // Validation
    var nameError: String?
    var typeError: String?
    var hasAttemptedStart: Bool = false

    // Location service
    let locationService = LocationService()

    var isLAWRoute: Bool {
        selectedHikeType?.name == "LAW-route"
    }

    var isValid: Bool {
        // Only show validation state if user has attempted to start
        guard hasAttemptedStart else { return true }
        return nameError == nil && typeError == nil
    }

    var canStart: Bool {
        // Check if form is actually valid (for button enabling)
        selectedHikeType != nil && !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    @discardableResult
    func validate() -> Bool {
        hasAttemptedStart = true

        // Reset errors
        nameError = nil
        typeError = nil

        // Validate type
        if selectedHikeType == nil {
            typeError = "Selecteer een type wandeling"
        }

        // Validate name
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Vul een naam in"
        }

        return nameError == nil && typeError == nil
    }

    func updateNameFromType() {
        // Auto-fill name ONLY for LAW routes
        // Regular hikes: leave name empty for user to fill
        if isLAWRoute, let lawRoute = selectedLAWRoute {
            name = lawRoute.name
        } else {
            // For regular hikes: clear any auto-filled name
            // User must explicitly type their hike name
            name = ""
        }
    }

    func fetchCurrentLocation() {
        locationService.fetchCurrentLocation { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let locationData):
                self.startLocationName = locationData.name
                self.startLatitude = locationData.latitude
                self.startLongitude = locationData.longitude

            case .failure:
                // Error is already set in locationService
                break
            }
        }
    }
}
