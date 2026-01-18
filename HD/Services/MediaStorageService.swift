import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Service voor het opslaan van media files in app storage
final class MediaStorageService {
    static let shared = MediaStorageService()

    private let fileManager = FileManager.default

    private init() {
        createDirectoriesIfNeeded()
    }

    // MARK: - Directories

    private func createDirectoriesIfNeeded() {
        createDirectory(for: .photos)
        createDirectory(for: .audio)
    }

    private func createDirectory(for type: MediaType) {
        guard let url = getDirectoryURL(for: type) else { return }

        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    private func getDirectoryURL(for type: MediaType) -> URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        switch type {
        case .photos:
            return documentsURL.appendingPathComponent("Photos")
        case .audio:
            return documentsURL.appendingPathComponent("Audio")
        }
    }

    // MARK: - Save

    func saveImage(_ image: UIImage, id: UUID = UUID()) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let directoryURL = getDirectoryURL(for: .photos) else {
            return nil
        }

        let fileName = "\(id.uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    func saveAudioData(_ data: Data, id: UUID = UUID()) -> String? {
        guard let directoryURL = getDirectoryURL(for: .audio) else {
            return nil
        }

        let fileName = "\(id.uuidString).m4a"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving audio: \(error)")
            return nil
        }
    }

    // MARK: - Load

    func loadImage(fileName: String) -> UIImage? {
        guard let directoryURL = getDirectoryURL(for: .photos) else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func getFileURL(for fileName: String, type: MediaType) -> URL? {
        guard let directoryURL = getDirectoryURL(for: type) else {
            return nil
        }

        return directoryURL.appendingPathComponent(fileName)
    }

    // MARK: - Delete

    func deleteFile(fileName: String, type: MediaType) {
        guard let fileURL = getFileURL(for: fileName, type: type) else {
            return
        }

        try? fileManager.removeItem(at: fileURL)
    }

    // MARK: - Types

    enum MediaType {
        case photos
        case audio
    }
}
