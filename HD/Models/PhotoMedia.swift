import Foundation
import SwiftData

@Model
final class PhotoMedia {
    // MARK: - Properties (Met default waarden voor CloudKit)
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var caption: String = ""

    // File reference
    var localFileName: String?
    var remoteURL: String?
    var isUploaded: Bool = false

    // Metadata
    var latitude: Double?
    var longitude: Double?
    var sortOrder: Int = 0

    // Relationship
    // Al optioneel, dus dit is correct voor CloudKit
    var hike: Hike?

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        caption: String = "",
        localFileName: String? = nil,
        remoteURL: String? = nil,
        isUploaded: Bool = false,
        latitude: Double? = nil,
        longitude: Double? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.caption = caption
        self.localFileName = localFileName
        self.remoteURL = remoteURL
        self.isUploaded = isUploaded
        self.latitude = latitude
        self.longitude = longitude
        self.sortOrder = sortOrder
    }

    // MARK: - Helpers
    var localFileURL: URL? {
        guard let fileName = localFileName else { return nil }

        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsURL.appendingPathComponent("Photos").appendingPathComponent(fileName)
    }
}
