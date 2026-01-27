import Foundation
import ImageIO
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif

/// Utility voor media conversies
final class MediaStorageService {
    static let shared = MediaStorageService()

    private init() {}

    // MARK: - Image Conversion

    func imageToData(_ image: UIImage, compressionQuality: CGFloat = 0.8) -> Data? {
        heicData(from: image, quality: compressionQuality) ?? image.jpegData(compressionQuality: compressionQuality)
    }

    /// Downscale en comprimeer een UIImage voor opslag.
    /// Schaalt de langste zijde naar maxDimension (alleen als het beeld groter is).
    /// Gebruikt HEIC voor kleinere bestanden, met JPEG als fallback.
    func compressImage(_ image: UIImage, maxDimension: CGFloat = 1000, quality: CGFloat = 0.5) -> Data? {
        let size = image.size
        let longestSide = max(size.width, size.height)

        // Alleen downscalen als nodig
        let targetImage: UIImage
        if longestSide > maxDimension {
            let scale = maxDimension / longestSide
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)

            let renderer = UIGraphicsImageRenderer(size: newSize)
            targetImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            targetImage = image
        }

        // Probeer HEIC, fallback naar JPEG
        let result = heicData(from: targetImage, quality: quality)
            ?? targetImage.jpegData(compressionQuality: quality)
        #if DEBUG
        if let result {
            print("[MediaStorage] Compressed image: \(result.count / 1024)KB")
        }
        #endif
        return result
    }

    // MARK: - HEIC Encoding

    /// Encodeer een UIImage als HEIC data. Geeft nil terug als HEIC niet wordt ondersteund.
    private func heicData(from image: UIImage, quality: CGFloat) -> Data? {
        guard let cgImage = image.cgImage else { return nil }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.heic.identifier as CFString,
            1,
            nil
        ) else { return nil }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    // MARK: - Temp Audio File

    func writeTempAudioFile(data: Data, id: UUID) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(id.uuidString).m4a")

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing temp audio file: \(error)")
            return nil
        }
    }
}
