import Foundation
import SwiftData

@Model
final class AudioMedia {
    // MARK: - Properties (Met default waarden voor CloudKit)
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var name: String = "Opname"
    var duration: Double = 0 // in seconds

    // Audio data (stored as CKAsset via CloudKit sync)
    @Attribute(.externalStorage) var audioData: Data?

    // Metadata
    var latitude: Double?
    var longitude: Double?
    var sortOrder: Int = 0

    // Relationship
    var hike: Hike?

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        name: String = "Opname",
        duration: Double = 0,
        audioData: Data? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.duration = duration
        self.audioData = audioData
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

    var temporaryFileURL: URL? {
        guard let audioData else { return nil }
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(id.uuidString).m4a")

        // Write to temp file if it doesn't exist yet
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            try? audioData.write(to: fileURL)
        }

        return fileURL
    }
}
