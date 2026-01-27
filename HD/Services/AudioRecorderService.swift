import Foundation
import AVFoundation

/// Service voor audio opname met AVFoundation
@Observable
final class AudioRecorderService: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?

    private(set) var isRecording = false
    private(set) var isPlaying = false
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var audioLevel: Float = 0.0

    // Playback state
    private(set) var playbackCurrentTime: TimeInterval = 0
    private(set) var playbackDuration: TimeInterval = 0

    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var currentRecordingURL: URL?

    override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Recording

    func startRecording() -> Bool {
        // Create temporary file URL
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 48000,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: tempURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            currentRecordingURL = tempURL
            isRecording = true
            recordingDuration = 0
            audioLevel = 0.0

            // Start timer for duration and audio level
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.audioRecorder?.updateMeters()

                self.recordingDuration = self.audioRecorder?.currentTime ?? 0

                // Get audio level (peak power normalized to 0-1)
                let peakPower = self.audioRecorder?.peakPower(forChannel: 0) ?? -160
                // Convert dB to linear scale (0-1)
                let normalized = pow(10, peakPower / 20)
                self.audioLevel = max(0, min(1, normalized))
            }

            return true
        } catch {
            print("Failed to start recording: \(error)")
            return false
        }
    }

    func stopRecording() -> (url: URL, duration: TimeInterval)? {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil

        isRecording = false
        audioLevel = 0.0

        guard let url = currentRecordingURL else {
            return nil
        }

        let duration = recordingDuration
        currentRecordingURL = nil
        recordingDuration = 0

        return (url, duration)
    }

    func cancelRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil

        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }

        isRecording = false
        audioLevel = 0.0
        currentRecordingURL = nil
        recordingDuration = 0
    }

    // MARK: - Playback

    func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()

            isPlaying = true
            playbackDuration = audioPlayer?.duration ?? 0
            playbackCurrentTime = 0

            // Start playback timer to update current time
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.playbackCurrentTime = self.audioPlayer?.currentTime ?? 0
            }
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        playbackTimer?.invalidate()
        playbackTimer = nil

        isPlaying = false
        playbackCurrentTime = 0
        playbackDuration = 0
    }

    func seekTo(time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        playbackCurrentTime = time
    }

    func saveRecording(tempURL: URL, id: UUID) -> Data? {
        do {
            let data = try Data(contentsOf: tempURL)

            // Delete temp file
            try? FileManager.default.removeItem(at: tempURL)

            return data
        } catch {
            print("Failed to save recording: \(error)")
            return nil
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorderService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackTimer?.invalidate()
        playbackTimer = nil

        isPlaying = false
        playbackCurrentTime = 0
        playbackDuration = 0
    }
}
