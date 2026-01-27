import Foundation
import SwiftData
import UIKit

@Model
final class PhotoMedia {
    // MARK: - Properties (Met default waarden voor CloudKit)
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var caption: String = ""

    // Image data (stored as CKAsset via CloudKit sync)
    @Attribute(.externalStorage) var imageData: Data?

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
        caption: String = "",
        imageData: Data? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.caption = caption
        self.imageData = imageData
        self.latitude = latitude
        self.longitude = longitude
        self.sortOrder = sortOrder
    }

    // MARK: - Helpers
    var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
}
