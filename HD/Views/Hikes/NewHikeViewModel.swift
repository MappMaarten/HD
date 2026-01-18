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

    // Location service
    let locationService = LocationService()

    var isLAWRoute: Bool {
        selectedHikeType?.name == "LAW-route"
    }

    var isValid: Bool {
        validate()
        return nameError == nil && typeError == nil
    }

    @discardableResult
    func validate() -> Bool {
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
        // Auto-fill name based on type or LAW route
        if isLAWRoute, let lawRoute = selectedLAWRoute {
            name = lawRoute.name
            if lawStageNumber > 0 {
                name += " - Etappe \(lawStageNumber)"
            }
        } else if let hikeType = selectedHikeType, name.isEmpty {
            name = hikeType.name
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

            case .failure(let error):
                // Error is already set in locationService
                break
            }
        }
    }
}
