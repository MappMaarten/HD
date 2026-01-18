import Foundation
import SwiftData

@Model
final class Hike {
    // MARK: - Identity
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var status: String = "inProgress" // "inProgress" or "completed"

    // MARK: - Start Phase
    var name: String = ""
    var type: String = ""
    var companions: String = ""
    var startLatitude: Double?
    var startLongitude: Double?
    var startLocationName: String?
    var startTime: Date = Date()
    var startMood: Int = 5

    // MARK: - During Hike
    var story: String = ""
    var terrainDescription: String = ""
    var weatherDescription: String = ""
    var notes: String = ""
    var animalCount: Int = 0
    var pauseCount: Int = 0
    var meetingCount: Int = 0

    // MARK: - End Phase
    var endTime: Date?
    var distance: Double?
    var rating: Int?
    var endLocationName: String?
    var endLatitude: Double?
    var endLongitude: Double?
    var endMood: Int?
    var reflection: String = ""

    // MARK: - LAW Route (Optional)
    var lawRouteName: String?
    var lawStageNumber: Int?

    // MARK: - Media Relationships
    // Belangrijk: Voor CloudKit moeten relaties ALTIJD optioneel zijn.
    @Relationship(deleteRule: .cascade, inverse: \PhotoMedia.hike)
    var photos: [PhotoMedia]? = []

    @Relationship(deleteRule: .cascade, inverse: \AudioMedia.hike)
    var audioRecordings: [AudioMedia]? = []

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        status: String = "inProgress",
        name: String = "",
        type: String = "",
        companions: String = "",
        startLatitude: Double? = nil,
        startLongitude: Double? = nil,
        startLocationName: String? = nil,
        startTime: Date = Date(),
        startMood: Int = 5,
        story: String = "",
        terrainDescription: String = "",
        weatherDescription: String = "",
        notes: String = "",
        animalCount: Int = 0,
        pauseCount: Int = 0,
        meetingCount: Int = 0,
        endTime: Date? = nil,
        distance: Double? = nil,
        rating: Int? = nil,
        endLocationName: String? = nil,
        endLatitude: Double? = nil,
        endLongitude: Double? = nil,
        endMood: Int? = nil,
        reflection: String = "",
        lawRouteName: String? = nil,
        lawStageNumber: Int? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.name = name
        self.type = type
        self.companions = companions
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.startLocationName = startLocationName
        self.startTime = startTime
        self.startMood = startMood
        self.story = story
        self.terrainDescription = terrainDescription
        self.weatherDescription = weatherDescription
        self.notes = notes
        self.animalCount = animalCount
        self.pauseCount = pauseCount
        self.meetingCount = meetingCount
        self.endTime = endTime
        self.distance = distance
        self.rating = rating
        self.endLocationName = endLocationName
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.endMood = endMood
        self.reflection = reflection
        self.lawRouteName = lawRouteName
        self.lawStageNumber = lawStageNumber
    }
}
