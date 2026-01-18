import Foundation
import CoreLocation

@Observable
final class LocationService: NSObject {
    var isLoadingLocation: Bool = false
    var locationError: String?
    var fetchedLatitude: Double?
    var fetchedLongitude: Double?

    private let locationManager = CLLocationManager()
    private var geocodingCompletion: ((Result<LocationData, LocationError>) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchCurrentLocation(completion: @escaping (Result<LocationData, LocationError>) -> Void) {
        isLoadingLocation = true
        locationError = nil
        geocodingCompletion = completion

        // Request permission first
        locationManager.requestWhenInUseAuthorization()

        // Get current location
        guard let location = locationManager.location else {
            isLoadingLocation = false
            locationError = "Kon locatie niet ophalen"
            completion(.failure(.locationUnavailable))
            return
        }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        // Store coordinates
        fetchedLatitude = latitude
        fetchedLongitude = longitude

        // Reverse geocode to get address
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            self.isLoadingLocation = false

            if error != nil {
                self.locationError = "Kon adres niet ophalen"
                completion(.failure(.geocodingFailed))
                return
            }

            if let placemark = placemarks?.first {
                let locationData = self.parseLocationData(from: placemark, latitude: latitude, longitude: longitude)
                completion(.success(locationData))
            } else {
                self.locationError = "Kon adres niet vinden"
                completion(.failure(.noPlacemarkFound))
            }
        }
    }

    private func parseLocationData(from placemark: CLPlacemark, latitude: Double, longitude: Double) -> LocationData {
        var locationParts: [String] = []

        // Add street/area
        if let street = placemark.thoroughfare {
            locationParts.append(street)
        } else if let area = placemark.locality {
            locationParts.append(area)
        } else if let subArea = placemark.subLocality {
            locationParts.append(subArea)
        }

        // Add city
        if let city = placemark.locality {
            if !locationParts.contains(city) {
                locationParts.append(city)
            }
        }

        let locationName = locationParts.joined(separator: ", ")

        return LocationData(
            name: locationName,
            latitude: latitude,
            longitude: longitude,
            street: placemark.thoroughfare,
            city: placemark.locality,
            country: placemark.country
        )
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle authorization changes if needed
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates if needed for real-time tracking
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoadingLocation = false
        locationError = "Locatiefout: \(error.localizedDescription)"
    }
}

// MARK: - Supporting Types
struct LocationData {
    let name: String
    let latitude: Double
    let longitude: Double
    let street: String?
    let city: String?
    let country: String?
}

enum LocationError: Error {
    case locationUnavailable
    case geocodingFailed
    case noPlacemarkFound
    case permissionDenied

    var description: String {
        switch self {
        case .locationUnavailable:
            return "Kon locatie niet ophalen"
        case .geocodingFailed:
            return "Kon adres niet ophalen"
        case .noPlacemarkFound:
            return "Kon adres niet vinden"
        case .permissionDenied:
            return "Locatietoegang geweigerd"
        }
    }
}
