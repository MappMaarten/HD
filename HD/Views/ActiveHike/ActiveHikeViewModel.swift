import Foundation
import SwiftData

@Observable
final class ActiveHikeViewModel {
    var hike: Hike

    init(hike: Hike) {
        self.hike = hike
    }

    func updateStory(_ text: String) {
        hike.story = text
        hike.updatedAt = Date()
    }

    func updateTerrainDescription(_ text: String) {
        hike.terrainDescription = text
        hike.updatedAt = Date()
    }

    func updateWeatherDescription(_ text: String) {
        hike.weatherDescription = text
        hike.updatedAt = Date()
    }

    func updateNotes(_ text: String) {
        hike.notes = text
        hike.updatedAt = Date()
    }

    func incrementAnimalCount() {
        hike.animalCount += 1
        hike.updatedAt = Date()
    }

    func decrementAnimalCount() {
        if hike.animalCount > 0 {
            hike.animalCount -= 1
            hike.updatedAt = Date()
        }
    }

    func incrementPauseCount() {
        hike.pauseCount += 1
        hike.updatedAt = Date()
    }

    func decrementPauseCount() {
        if hike.pauseCount > 0 {
            hike.pauseCount -= 1
            hike.updatedAt = Date()
        }
    }

    func incrementMeetingCount() {
        hike.meetingCount += 1
        hike.updatedAt = Date()
    }

    func decrementMeetingCount() {
        if hike.meetingCount > 0 {
            hike.meetingCount -= 1
            hike.updatedAt = Date()
        }
    }
}
