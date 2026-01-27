import Foundation
import SwiftData
import UIKit
import AVFoundation

class SampleDataService {
    // MARK: - UserDefaults Key
    private static let sampleHikesKey = "sampleHikeIDs"

    // MARK: - Public Methods

    /// Creates 10 sample hikes with media and returns the count
    static func createSampleHikes(context: ModelContext) throws -> Int {
        var createdCount = 0

        for hikeData in sampleHikeData {
            let hike = Hike(
                id: hikeData.id,
                createdAt: hikeData.createdAt,
                updatedAt: hikeData.createdAt,
                status: "completed",
                name: hikeData.name,
                type: hikeData.type,
                companions: hikeData.companions,
                startLatitude: hikeData.startLatitude,
                startLongitude: hikeData.startLongitude,
                startLocationName: hikeData.startLocationName,
                startTime: hikeData.startTime,
                startMood: hikeData.startMood,
                story: hikeData.story,
                terrainDescription: hikeData.terrainDescription,
                weatherDescription: hikeData.weatherDescription,
                notes: hikeData.notes,
                animalCount: hikeData.animalCount,
                pauseCount: hikeData.pauseCount,
                meetingCount: hikeData.meetingCount,
                endTime: hikeData.endTime,
                distance: hikeData.distance,
                rating: hikeData.rating,
                endLocationName: hikeData.endLocationName,
                endLatitude: hikeData.endLatitude,
                endLongitude: hikeData.endLongitude,
                endMood: hikeData.endMood,
                reflection: hikeData.reflection,
                lawRouteName: hikeData.lawRouteName,
                lawStageNumber: hikeData.lawStageNumber
            )

            context.insert(hike)

            // Add photos
            for (index, photoData) in hikeData.photos.enumerated() {
                let photo = PhotoMedia(
                    createdAt: photoData.createdAt,
                    caption: photoData.caption,
                    imageData: generatePlaceholderImage(color: photoData.color, size: CGSize(width: 100, height: 100)),
                    latitude: photoData.latitude,
                    longitude: photoData.longitude,
                    sortOrder: index
                )
                photo.hike = hike
                context.insert(photo)
            }

            // Add audio recordings
            for (index, audioData) in hikeData.audioRecordings.enumerated() {
                let audio = AudioMedia(
                    createdAt: audioData.createdAt,
                    name: audioData.name,
                    duration: audioData.duration,
                    audioData: generateSilentAudioData(duration: audioData.duration),
                    latitude: audioData.latitude,
                    longitude: audioData.longitude,
                    sortOrder: index
                )
                audio.hike = hike
                context.insert(audio)
            }

            // Track this sample hike
            storeSampleHikeID(hike.id)
            createdCount += 1
        }

        try context.save()
        return createdCount
    }

    /// Deletes all sample hikes and returns the count
    static func deleteSampleHikes(context: ModelContext) throws -> Int {
        let sampleIDs = getSampleHikeIDs()
        var deletedCount = 0

        for id in sampleIDs {
            let descriptor = FetchDescriptor<Hike>(
                predicate: #Predicate { hike in
                    hike.id == id
                }
            )

            if let hikes = try? context.fetch(descriptor),
               let hike = hikes.first {
                context.delete(hike)
                deletedCount += 1
            }
        }

        try context.save()
        clearSampleHikeIDs()
        return deletedCount
    }

    // MARK: - Private Helpers

    private static func storeSampleHikeID(_ id: UUID) {
        var ids = getSampleHikeIDs()
        ids.append(id)
        UserDefaults.standard.set(ids.map { $0.uuidString }, forKey: sampleHikesKey)
    }

    private static func getSampleHikeIDs() -> [UUID] {
        guard let strings = UserDefaults.standard.stringArray(forKey: sampleHikesKey) else {
            return []
        }
        return strings.compactMap { UUID(uuidString: $0) }
    }

    private static func clearSampleHikeIDs() {
        UserDefaults.standard.removeObject(forKey: sampleHikesKey)
    }

    private static func generatePlaceholderImage(color: UIColor, size: CGSize) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.jpegData(compressionQuality: 0.8)
    }

    private static func generateSilentAudioData(duration: Double) -> Data? {
        // Create a minimal silent audio file (1-2 seconds of silence)
        // Using a simple approach: return minimal M4A data
        // For a real implementation, you'd use AVAssetWriter, but for testing this minimal approach works

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")

        // Create silent audio using AVAudioFile
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount = AVAudioFrameCount(duration * format.sampleRate)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }

        buffer.frameLength = frameCount

        // Fill with silence (zeros)
        if let data = buffer.floatChannelData {
            let channelData = data[0]
            for i in 0..<Int(frameCount) {
                channelData[i] = 0.0
            }
        }

        do {
            let audioFile = try AVAudioFile(forWriting: tempURL, settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderBitRateKey: 64000
            ])

            try audioFile.write(from: buffer)

            let data = try Data(contentsOf: tempURL)
            try? FileManager.default.removeItem(at: tempURL)

            return data
        } catch {
            print("Error generating silent audio: \(error)")
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }

    // MARK: - Sample Data Definitions

    private struct SamplePhotoData {
        let createdAt: Date
        let caption: String
        let color: UIColor
        let latitude: Double?
        let longitude: Double?
    }

    private struct SampleAudioData {
        let createdAt: Date
        let name: String
        let duration: Double
        let latitude: Double?
        let longitude: Double?
    }

    private struct SampleHikeData {
        let id: UUID
        let createdAt: Date
        let name: String
        let type: String
        let companions: String
        let startLatitude: Double
        let startLongitude: Double
        let startLocationName: String
        let startTime: Date
        let startMood: Int
        let story: String
        let terrainDescription: String
        let weatherDescription: String
        let notes: String
        let animalCount: Int
        let pauseCount: Int
        let meetingCount: Int
        let endTime: Date
        let distance: Double
        let rating: Int
        let endLocationName: String?
        let endLatitude: Double?
        let endLongitude: Double?
        let endMood: Int
        let reflection: String
        let lawRouteName: String?
        let lawStageNumber: Int?
        let photos: [SamplePhotoData]
        let audioRecordings: [SampleAudioData]
    }

    private static let sampleHikeData: [SampleHikeData] = {
        let calendar = Calendar.current
        let now = Date()

        // Helper to create dates in the past
        func daysAgo(_ days: Int, hours: Int = 10, minutes: Int = 0) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now)!
                .addingTimeInterval(TimeInterval(hours * 3600 + minutes * 60))
        }

        return [
            // Hike 1: Boswandeling in Utrechtse Heuvelrug
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(60),
                name: "Boswandeling in Utrechtse Heuvelrug",
                type: "Boswandeling",
                companions: "Emma, Daan",
                startLatitude: 52.0347,
                startLongitude: 5.3428,
                startLocationName: "Doorn",
                startTime: daysAgo(60, hours: 10, minutes: 15),
                startMood: 7,
                story: "Prachtige boswandeling door de Utrechtse Heuvelrug. Het pad voerde ons langs oude eikenbomen en door dichte dennenbossen. De herfstbladeren kraakten onder onze voeten.",
                terrainDescription: "Afwisselend bos met zandpaden en enkele heuvels. Goed begaanbaar.",
                weatherDescription: "Zonnig met bewolking, 15°C",
                notes: "Volgende keer de langere route nemen via de Lage Vuursche",
                animalCount: 3,
                pauseCount: 2,
                meetingCount: 5,
                endTime: daysAgo(60, hours: 12, minutes: 30),
                distance: 8.5,
                rating: 8,
                endLocationName: "Doorn",
                endLatitude: 52.0347,
                endLongitude: 5.3428,
                endMood: 9,
                reflection: "Heerlijke ontspannende wandeling. De combinatie van bos en heuvels maakt dit gebied uniek.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(60, hours: 10, minutes: 30), caption: "Start in het bos", color: .systemGreen, latitude: 52.0350, longitude: 5.3430),
                    SamplePhotoData(createdAt: daysAgo(60, hours: 11, minutes: 0), caption: "Oude eikenboom", color: .systemBrown, latitude: 52.0380, longitude: 5.3450),
                    SamplePhotoData(createdAt: daysAgo(60, hours: 11, minutes: 45), caption: "Uitzicht vanaf heuvel", color: .systemGreen, latitude: 52.0420, longitude: 5.3480),
                    SamplePhotoData(createdAt: daysAgo(60, hours: 12, minutes: 15), caption: "Herfstbladeren", color: .systemOrange, latitude: 52.0360, longitude: 5.3440)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(60, hours: 10, minutes: 45), name: "Vogels in het bos", duration: 45, latitude: 52.0360, longitude: 5.3440),
                    SampleAudioData(createdAt: daysAgo(60, hours: 12, minutes: 0), name: "Reflectie bij pauze", duration: 62, latitude: 52.0400, longitude: 5.3470)
                ]
            ),

            // Hike 2: Pieterpad Etappe 1
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(50),
                name: "Pieterpad Etappe 1",
                type: "LAW-route",
                companions: "Lisa, Tom, Sophie",
                startLatitude: 53.3400,
                startLongitude: 6.1553,
                startLocationName: "Pieterburen",
                startTime: daysAgo(50, hours: 8, minutes: 30),
                startMood: 8,
                story: "De start van ons Pieterpad avontuur! Begonnen bij de Waddenzee in Pieterburen. Het noordelijkste punt van Nederland voelde speciaal. Mooie route door typisch Gronings landschap.",
                terrainDescription: "Vlak met dijken, door weilanden en kleine dorpjes. Goed begaanbaar.",
                weatherDescription: "Bewolkt met opklaringen, 17°C, stevige wind",
                notes: "Accommodatie in Winsum was uitstekend",
                animalCount: 12,
                pauseCount: 3,
                meetingCount: 8,
                endTime: daysAgo(50, hours: 15, minutes: 15),
                distance: 24.3,
                rating: 9,
                endLocationName: "Winsum",
                endLatitude: 53.3258,
                endLongitude: 6.5247,
                endMood: 8,
                reflection: "Geweldige eerste etappe. We zijn klaar voor de rest van het Pieterpad!",
                lawRouteName: "Pieterpad",
                lawStageNumber: 1,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(50, hours: 8, minutes: 45), caption: "Start bij de Waddenzee", color: .systemBlue, latitude: 53.3400, longitude: 6.1553),
                    SamplePhotoData(createdAt: daysAgo(50, hours: 10, minutes: 30), caption: "Groninger landschap", color: .systemGreen, latitude: 53.3350, longitude: 6.2500),
                    SamplePhotoData(createdAt: daysAgo(50, hours: 12, minutes: 0), caption: "Lunch in dorpje", color: .systemGray, latitude: 53.3300, longitude: 6.3500),
                    SamplePhotoData(createdAt: daysAgo(50, hours: 13, minutes: 30), caption: "Koeien in de wei", color: .systemGreen, latitude: 53.3280, longitude: 6.4200),
                    SamplePhotoData(createdAt: daysAgo(50, hours: 15, minutes: 0), caption: "Aankomst Winsum", color: .systemGray, latitude: 53.3258, longitude: 6.5247)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(50, hours: 9, minutes: 30), name: "Geluid van de zee", duration: 38, latitude: 53.3380, longitude: 6.1800),
                    SampleAudioData(createdAt: daysAgo(50, hours: 12, minutes: 30), name: "Groepsgesprek bij lunch", duration: 85, latitude: 53.3300, longitude: 6.3500),
                    SampleAudioData(createdAt: daysAgo(50, hours: 14, minutes: 45), name: "Laatste kilometers", duration: 52, latitude: 53.3270, longitude: 6.4800)
                ]
            ),

            // Hike 3: Pieterpad Etappe 2
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(49),
                name: "Pieterpad Etappe 2",
                type: "LAW-route",
                companions: "Lisa, Tom, Sophie",
                startLatitude: 53.3258,
                startLongitude: 6.5247,
                startLocationName: "Winsum",
                startTime: daysAgo(49, hours: 9, minutes: 0),
                startMood: 7,
                story: "Tweede dag van het Pieterpad. Vandaag naar Groningen stad. De route voerde ons door mooie dorpen en uiteindelijk de stad in. Bijzonder om van platteland naar stedelijke omgeving te lopen.",
                terrainDescription: "Eerst vlak landschap, later stedelijk. Goed bewegwijzerd.",
                weatherDescription: "Droog, zonnig, 19°C",
                notes: "Goed eten gevonden in Groningen centrum",
                animalCount: 7,
                pauseCount: 4,
                meetingCount: 15,
                endTime: daysAgo(49, hours: 15, minutes: 20),
                distance: 22.7,
                rating: 8,
                endLocationName: "Groningen",
                endLatitude: 53.2194,
                endLongitude: 6.5665,
                endMood: 8,
                reflection: "Mooi contrast tussen platteland en stad. Groningen is een prachtige stad om aan te komen.",
                lawRouteName: "Pieterpad",
                lawStageNumber: 2,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(49, hours: 9, minutes: 30), caption: "Vertrek uit Winsum", color: .systemGray, latitude: 53.3258, longitude: 6.5247),
                    SamplePhotoData(createdAt: daysAgo(49, hours: 11, minutes: 0), caption: "Groninger dorpje", color: .systemGreen, latitude: 53.2800, longitude: 6.5400),
                    SamplePhotoData(createdAt: daysAgo(49, hours: 12, minutes: 30), caption: "Richting de stad", color: .systemGreen, latitude: 53.2500, longitude: 6.5500),
                    SamplePhotoData(createdAt: daysAgo(49, hours: 14, minutes: 0), caption: "Groningen centrum", color: .systemGray, latitude: 53.2194, longitude: 6.5665),
                    SamplePhotoData(createdAt: daysAgo(49, hours: 15, minutes: 15), caption: "Martinitoren", color: .systemGray, latitude: 53.2194, longitude: 6.5665)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(49, hours: 10, minutes: 30), name: "Ochtendoverleg", duration: 42, latitude: 53.3000, longitude: 6.5300),
                    SampleAudioData(createdAt: daysAgo(49, hours: 14, minutes: 30), name: "Stadse geluiden", duration: 55, latitude: 53.2194, longitude: 6.5665)
                ]
            ),

            // Hike 4: Pieterpad Etappe 3
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(48),
                name: "Pieterpad Etappe 3",
                type: "LAW-route",
                companions: "Lisa, Tom, Sophie",
                startLatitude: 53.2194,
                startLongitude: 6.5665,
                startLocationName: "Groningen",
                startTime: daysAgo(48, hours: 8, minutes: 45),
                startMood: 8,
                story: "Derde etappe van ons Pieterpad avontuur. Vanuit Groningen stad weer het platteland in richting Peize. Mooie afwisseling in landschap en verschillende dorpjes bezocht.",
                terrainDescription: "Vlak met enkele bossen. Mix van verharde en onverharde paden.",
                weatherDescription: "Wisselend bewolkt, 16°C, af en toe een bui",
                notes: "Ondanks de buien toch een mooie dag",
                animalCount: 9,
                pauseCount: 3,
                meetingCount: 6,
                endTime: daysAgo(48, hours: 15, minutes: 55),
                distance: 25.1,
                rating: 8,
                endLocationName: "Peize",
                endLatitude: 53.1464,
                endLongitude: 6.4947,
                endMood: 7,
                reflection: "Langste etappe tot nu toe, maar we hebben het goed gedaan. Klaar voor een rustdag.",
                lawRouteName: "Pieterpad",
                lawStageNumber: 3,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(48, hours: 9, minutes: 15), caption: "Verlaten Groningen", color: .systemGray, latitude: 53.2194, longitude: 6.5665),
                    SamplePhotoData(createdAt: daysAgo(48, hours: 11, minutes: 0), caption: "Bos bij Haren", color: .systemGreen, latitude: 53.1800, longitude: 6.5500),
                    SamplePhotoData(createdAt: daysAgo(48, hours: 12, minutes: 45), caption: "Lunchpauze", color: .systemBrown, latitude: 53.1650, longitude: 6.5200),
                    SamplePhotoData(createdAt: daysAgo(48, hours: 15, minutes: 30), caption: "Aankomst Peize", color: .systemGray, latitude: 53.1464, longitude: 6.4947)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(48, hours: 10, minutes: 0), name: "Motivatiepraat", duration: 68, latitude: 53.2000, longitude: 6.5600),
                    SampleAudioData(createdAt: daysAgo(48, hours: 13, minutes: 30), name: "Vogels in het bos", duration: 41, latitude: 53.1700, longitude: 6.5300),
                    SampleAudioData(createdAt: daysAgo(48, hours: 15, minutes: 0), name: "Laatste push", duration: 35, latitude: 53.1500, longitude: 6.5000)
                ]
            ),

            // Hike 5: Stadswandeling Amsterdam
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(35),
                name: "Stadswandeling Amsterdam",
                type: "Stadswandeling",
                companions: "Mark",
                startLatitude: 52.3791,
                startLongitude: 4.9003,
                startLocationName: "Amsterdam Centraal",
                startTime: daysAgo(35, hours: 13, minutes: 0),
                startMood: 7,
                story: "Mooie stadswandeling door Amsterdam. Via de grachten, Jordaan, en richting Vondelpark. Amsterdam laat zich prachtig te voet ontdekken.",
                terrainDescription: "Volledig verhard, grachten en straten. Druk met toeristen.",
                weatherDescription: "Zonnig, 21°C",
                notes: "Koffie gedronken in de Jordaan, aanrader!",
                animalCount: 2,
                pauseCount: 4,
                meetingCount: 25,
                endTime: daysAgo(35, hours: 14, minutes: 50),
                distance: 6.2,
                rating: 7,
                endLocationName: "Vondelpark",
                endLatitude: 52.3579,
                endLongitude: 4.8686,
                endMood: 8,
                reflection: "Fijne ontspannen wandeling door de stad. Amsterdam blijft mooi.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(35, hours: 13, minutes: 15), caption: "Grachten", color: .systemBlue, latitude: 52.3750, longitude: 4.8950),
                    SamplePhotoData(createdAt: daysAgo(35, hours: 13, minutes: 30), caption: "Bruggetje", color: .systemGray, latitude: 52.3720, longitude: 4.8900),
                    SamplePhotoData(createdAt: daysAgo(35, hours: 13, minutes: 55), caption: "Jordaan straatje", color: .systemGray, latitude: 52.3700, longitude: 4.8850),
                    SamplePhotoData(createdAt: daysAgo(35, hours: 14, minutes: 20), caption: "Museumplein", color: .systemGreen, latitude: 52.3580, longitude: 4.8820),
                    SamplePhotoData(createdAt: daysAgo(35, hours: 14, minutes: 40), caption: "Vijver Vondelpark", color: .systemBlue, latitude: 52.3579, longitude: 4.8686),
                    SamplePhotoData(createdAt: daysAgo(35, hours: 14, minutes: 48), caption: "Park bankje", color: .systemGreen, latitude: 52.3579, longitude: 4.8686)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(35, hours: 13, minutes: 40), name: "Grachtengordel sfeer", duration: 48, latitude: 52.3720, longitude: 4.8900),
                    SampleAudioData(createdAt: daysAgo(35, hours: 14, minutes: 35), name: "Vondelpark vogels", duration: 37, latitude: 52.3579, longitude: 4.8686)
                ]
            ),

            // Hike 6: Strandwandeling Zandvoort
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(28),
                name: "Strandwandeling Zandvoort",
                type: "Strandwandeling",
                companions: "Sarah, Kim",
                startLatitude: 52.3727,
                startLongitude: 4.5317,
                startLocationName: "Zandvoort aan Zee",
                startTime: daysAgo(28, hours: 10, minutes: 30),
                startMood: 8,
                story: "Heerlijke strandwandeling langs de Noord-Hollandse kust. De wind in je haar, de golven, het zand onder je voeten. Door de duinen terug. Perfect voor het hoofd leeg maken.",
                terrainDescription: "Strand en duinen. Zand en duinpaden.",
                weatherDescription: "Winderig maar droog, 18°C",
                notes: "Wind was flink, maar dat hoort bij het strand",
                animalCount: 8,
                pauseCount: 2,
                meetingCount: 12,
                endTime: daysAgo(28, hours: 13, minutes: 35),
                distance: 12.4,
                rating: 9,
                endLocationName: "Zandvoort aan Zee",
                endLatitude: 52.3727,
                endLongitude: 4.5317,
                endMood: 9,
                reflection: "Wat een heerlijke wandeling. Het strand blijft magisch, zeker met dit weer.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(28, hours: 10, minutes: 45), caption: "Start bij het strand", color: .systemYellow, latitude: 52.3727, longitude: 4.5317),
                    SamplePhotoData(createdAt: daysAgo(28, hours: 11, minutes: 15), caption: "Golven", color: .systemBlue, latitude: 52.3650, longitude: 4.5200),
                    SamplePhotoData(createdAt: daysAgo(28, hours: 11, minutes: 50), caption: "Schelpen", color: .systemYellow, latitude: 52.3580, longitude: 4.5100),
                    SamplePhotoData(createdAt: daysAgo(28, hours: 12, minutes: 30), caption: "Duinen", color: .systemYellow, latitude: 52.3600, longitude: 4.5150),
                    SamplePhotoData(createdAt: daysAgo(28, hours: 13, minutes: 15), caption: "Uitzicht over zee", color: .systemBlue, latitude: 52.3700, longitude: 4.5300)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(28, hours: 11, minutes: 0), name: "Golven en meeuwen", duration: 72, latitude: 52.3650, longitude: 4.5200),
                    SampleAudioData(createdAt: daysAgo(28, hours: 12, minutes: 45), name: "Wind in de duinen", duration: 44, latitude: 52.3600, longitude: 4.5150)
                ]
            ),

            // Hike 7: Blokje om in de buurt
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(15),
                name: "Blokje om in de buurt",
                type: "Blokje om",
                companions: "",
                startLatitude: 52.0907,
                startLongitude: 5.1214,
                startLocationName: "Utrecht - Lombok",
                startTime: daysAgo(15, hours: 18, minutes: 30),
                startMood: 6,
                story: "Korte avondwandeling door de buurt. Soms is een simpel blokje om precies wat je nodig hebt.",
                terrainDescription: "Stoepen en straten in de wijk.",
                weatherDescription: "Bewolkt, 14°C",
                notes: "Fijn om even de benen te strekken",
                animalCount: 3,
                pauseCount: 0,
                meetingCount: 4,
                endTime: daysAgo(15, hours: 19, minutes: 15),
                distance: 3.1,
                rating: 6,
                endLocationName: "Utrecht - Lombok",
                endLatitude: 52.0907,
                endLongitude: 5.1214,
                endMood: 7,
                reflection: "Soms is een kort rondje precies wat je nodig hebt.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(15, hours: 18, minutes: 45), caption: "Buurtstraat", color: .systemGray, latitude: 52.0920, longitude: 5.1230),
                    SamplePhotoData(createdAt: daysAgo(15, hours: 19, minutes: 0), caption: "Park in de buurt", color: .systemGreen, latitude: 52.0900, longitude: 5.1200)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(15, hours: 18, minutes: 50), name: "Avondgeluiden", duration: 28, latitude: 52.0920, longitude: 5.1230)
                ]
            ),

            // Hike 8: Klompenpad Overijssel
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(22),
                name: "Klompenpad Giethoorn",
                type: "Klompenpad",
                companions: "Bas, Anna",
                startLatitude: 52.7395,
                startLongitude: 6.0755,
                startLocationName: "Giethoorn",
                startTime: daysAgo(22, hours: 11, minutes: 0),
                startMood: 8,
                story: "Prachtig Klompenpad rond Giethoorn. Langs de waterrijke omgeving, door weilanden en langs oude boerderijen. Typisch Nederlands landschap.",
                terrainDescription: "Vlak, onverhard, door weilanden en langs water.",
                weatherDescription: "Zonnig, 20°C",
                notes: "Route is goed bewegwijzerd met klompjes",
                animalCount: 15,
                pauseCount: 2,
                meetingCount: 7,
                endTime: daysAgo(22, hours: 13, minutes: 40),
                distance: 9.7,
                rating: 9,
                endLocationName: "Giethoorn",
                endLatitude: 52.7395,
                endLongitude: 6.0755,
                endMood: 9,
                reflection: "Wat een schitterende omgeving. Giethoorn en omstreken zijn echt de moeite waard.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(22, hours: 11, minutes: 20), caption: "Gracht in Giethoorn", color: .systemBlue, latitude: 52.7395, longitude: 6.0755),
                    SamplePhotoData(createdAt: daysAgo(22, hours: 11, minutes: 50), caption: "Weiland met koeien", color: .systemGreen, latitude: 52.7450, longitude: 6.0800),
                    SamplePhotoData(createdAt: daysAgo(22, hours: 12, minutes: 30), caption: "Oude boerderij", color: .systemBrown, latitude: 52.7500, longitude: 6.0850),
                    SamplePhotoData(createdAt: daysAgo(22, hours: 13, minutes: 0), caption: "Sloot met eenden", color: .systemBlue, latitude: 52.7480, longitude: 6.0820),
                    SamplePhotoData(createdAt: daysAgo(22, hours: 13, minutes: 30), caption: "Terug in Giethoorn", color: .systemBlue, latitude: 52.7395, longitude: 6.0755)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(22, hours: 11, minutes: 35), name: "Water en vogels", duration: 56, latitude: 52.7420, longitude: 6.0780),
                    SampleAudioData(createdAt: daysAgo(22, hours: 12, minutes: 15), name: "Koeien in de wei", duration: 38, latitude: 52.7470, longitude: 6.0830),
                    SampleAudioData(createdAt: daysAgo(22, hours: 13, minutes: 15), name: "Sfeer Giethoorn", duration: 49, latitude: 52.7400, longitude: 6.0760)
                ]
            ),

            // Hike 9: Dagwandeling Veluwe
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(12),
                name: "Dagwandeling Veluwe",
                type: "Dagwandeling",
                companions: "Peter, Linda, Max",
                startLatitude: 52.0667,
                startLongitude: 5.9000,
                startLocationName: "Hoenderloo",
                startTime: daysAgo(12, hours: 9, minutes: 0),
                startMood: 8,
                story: "Volledige dagwandeling door de Veluwe. Van Hoenderloo naar Apeldoorn, door bossen, over heidevelden, en langs landgoederen. De variatie in landschap maakt de Veluwe uniek.",
                terrainDescription: "Afwisselend bos, heide, zandpaden. Enkele heuvels.",
                weatherDescription: "Zonnig, 19°C",
                notes: "Lunch gedaan bij bezoekerscentrum",
                animalCount: 18,
                pauseCount: 4,
                meetingCount: 20,
                endTime: daysAgo(12, hours: 14, minutes: 15),
                distance: 18.6,
                rating: 9,
                endLocationName: "Apeldoorn",
                endLatitude: 52.2112,
                endLongitude: 5.9699,
                endMood: 8,
                reflection: "Fantastische dagwandeling. De Veluwe blijft mijn favoriete wandelgebied.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(12, hours: 9, minutes: 30), caption: "Dennenbos", color: .systemGreen, latitude: 52.0700, longitude: 5.9100),
                    SamplePhotoData(createdAt: daysAgo(12, hours: 10, minutes: 15), caption: "Heideveld", color: .systemPurple, latitude: 52.0900, longitude: 5.9300),
                    SamplePhotoData(createdAt: daysAgo(12, hours: 11, minutes: 0), caption: "Zandverstuiving", color: .systemYellow, latitude: 52.1100, longitude: 5.9400),
                    SamplePhotoData(createdAt: daysAgo(12, hours: 11, minutes: 45), caption: "Landgoed", color: .systemGreen, latitude: 52.1400, longitude: 5.9500),
                    SamplePhotoData(createdAt: daysAgo(12, hours: 12, minutes: 30), caption: "Hert gespot!", color: .systemBrown, latitude: 52.1600, longitude: 5.9600),
                    SamplePhotoData(createdAt: daysAgo(12, hours: 13, minutes: 15), caption: "Bos bij Apeldoorn", color: .systemGreen, latitude: 52.1900, longitude: 5.9650),
                    SamplePhotoData(createdAt: daysAgo(12, hours: 14, minutes: 0), caption: "Aankomst Apeldoorn", color: .systemGray, latitude: 52.2112, longitude: 5.9699)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(12, hours: 9, minutes: 45), name: "Vogels in het bos", duration: 52, latitude: 52.0750, longitude: 5.9150),
                    SampleAudioData(createdAt: daysAgo(12, hours: 11, minutes: 30), name: "Groepsgesprek", duration: 78, latitude: 52.1300, longitude: 5.9450),
                    SampleAudioData(createdAt: daysAgo(12, hours: 12, minutes: 45), name: "Hert roept", duration: 24, latitude: 52.1650, longitude: 5.9620),
                    SampleAudioData(createdAt: daysAgo(12, hours: 13, minutes: 45), name: "Laatste kilometers", duration: 61, latitude: 52.2000, longitude: 5.9670)
                ]
            ),

            // Hike 10: Bergwandeling Limburg
            SampleHikeData(
                id: UUID(),
                createdAt: daysAgo(5),
                name: "Bergwandeling Zuid-Limburg",
                type: "Bergwandeling",
                companions: "Eva, Robin",
                startLatitude: 50.8656,
                startLongitude: 5.8307,
                startLocationName: "Valkenburg",
                startTime: daysAgo(5, hours: 10, minutes: 30),
                startMood: 9,
                story: "Prachtige heuvelachtige wandeling door Zuid-Limburg. Van Valkenburg naar Maastricht, over de heuvels, door bossen en met fantastische uitzichten. Dit voelt als wandelen in het buitenland!",
                terrainDescription: "Heuvelachtig, bospaden, enkele steile stukken.",
                weatherDescription: "Zonnig, 22°C",
                notes: "Zwaarder dan verwacht, maar geweldige uitzichten",
                animalCount: 11,
                pauseCount: 5,
                meetingCount: 14,
                endTime: daysAgo(5, hours: 14, minutes: 50),
                distance: 14.3,
                rating: 10,
                endLocationName: "Maastricht",
                endLatitude: 50.8514,
                endLongitude: 5.6909,
                endMood: 9,
                reflection: "Wat een schitterende wandeling! Zuid-Limburg is echt uniek in Nederland. De hoogtemeters maken het uitdagend maar de uitzichten zijn het meer dan waard.",
                lawRouteName: nil,
                lawStageNumber: nil,
                photos: [
                    SamplePhotoData(createdAt: daysAgo(5, hours: 10, minutes: 45), caption: "Start in Valkenburg", color: .systemGray, latitude: 50.8656, longitude: 5.8307),
                    SamplePhotoData(createdAt: daysAgo(5, hours: 11, minutes: 30), caption: "Eerste heuvel", color: .systemGreen, latitude: 50.8600, longitude: 5.8100),
                    SamplePhotoData(createdAt: daysAgo(5, hours: 12, minutes: 15), caption: "Uitzicht over Geul dal", color: .systemGreen, latitude: 50.8550, longitude: 5.7800),
                    SamplePhotoData(createdAt: daysAgo(5, hours: 13, minutes: 0), caption: "Bos op helling", color: .systemGreen, latitude: 50.8530, longitude: 5.7400),
                    SamplePhotoData(createdAt: daysAgo(5, hours: 13, minutes: 45), caption: "Uitzicht Maastricht", color: .systemBlue, latitude: 50.8520, longitude: 5.7100),
                    SamplePhotoData(createdAt: daysAgo(5, hours: 14, minutes: 35), caption: "Aankomst Maastricht centrum", color: .systemGray, latitude: 50.8514, longitude: 5.6909)
                ],
                audioRecordings: [
                    SampleAudioData(createdAt: daysAgo(5, hours: 11, minutes: 15), name: "Op weg naar boven", duration: 48, latitude: 50.8620, longitude: 5.8150),
                    SampleAudioData(createdAt: daysAgo(5, hours: 12, minutes: 30), name: "Reflectie bij uitzicht", duration: 85, latitude: 50.8540, longitude: 5.7750),
                    SampleAudioData(createdAt: daysAgo(5, hours: 14, minutes: 0), name: "Laatste stuk naar Maastricht", duration: 54, latitude: 50.8518, longitude: 5.7050)
                ]
            )
        ]
    }()
}
