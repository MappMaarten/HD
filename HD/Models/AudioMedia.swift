import Foundation
import SwiftData

@Model
final class AudioMedia {
    // MARK: - Properties (Met default waarden voor CloudKit)
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var name: String = "Opname"
    var duration: Double = 0 // in seconds

    // File reference
    var localFileName: String? // Al optioneel, dus OK
    var remoteURL: String?
    var isUploaded: Bool = false

    // Metadata
    var latitude: Double?
    var longitude: Double?
    var sortOrder: Int = 0

    // Relationship
    // Belangrijk: Relaties MOETEN optioneel zijn voor CloudKit integration
    var hike: Hike?

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        name: String = "Opname",
        duration: Double = 0,
        localFileName: String? = nil,
        remoteURL: String? = nil,
        isUploaded: Bool = false,
        latitude: Double? = nil,
        longitude: Double? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.duration = duration
        self.localFileName = localFileName
        self.remoteURL = remoteURL
        self.isUploaded = isUploaded
        self.latitude = latitude
        self.longitude = longitude
        self.sortOrder = sortOrder
    }

    // MARK: - Helpers
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var localFileURL: URL? {
        guard let fileName = localFileName else { return nil }
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent("Audio").appendingPathComponent(fileName)
    }
}
