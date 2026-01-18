import SwiftUI
import SwiftData

struct AudioTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var audioRecorder = AudioRecorderService()
    @State private var showNameDialog = false
    @State private var recordingName = ""
    @State private var pendingRecording: (url: URL, duration: TimeInterval)?

    var audioRecordings: [AudioMedia] {
        viewModel.hike.audioRecordings ?? []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if audioRecordings.isEmpty && !audioRecorder.isRecording {
                    emptyState
                } else {
                    recordingsList
                }

                Spacer()

                if audioRecorder.isRecording {
                    recordingIndicator
                }

                recordButton
                    .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("Audio")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Opname naam", isPresented: $showNameDialog) {
                TextField("Naam (optioneel)", text: $recordingName)
                Button("Opslaan") {
                    saveRecording(name: recordingName)
                }
                Button("Standaard naam") {
                    saveRecording(name: "")
                }
                Button("Annuleer", role: .cancel) {
                    // Delete temp file
                    if let pending = pendingRecording {
                        try? FileManager.default.removeItem(at: pending.url)
                    }
                    pendingRecording = nil
                    recordingName = ""
                }
            } message: {
                Text("Geef je opname een naam of gebruik de standaard naam")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            EmptyStateView(
                icon: "waveform",
                title: "Geen opnames",
                message: "Tik op de microfoon om een audio notitie op te nemen"
            )

            Spacer()
        }
    }

    private var recordingsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                SectionHeader(
                    title: "Opnames",
                    subtitle: "\(audioRecordings.count) opname(s)"
                )

                ForEach(audioRecordings) { recording in
                    AudioRecordingRow(
                        recording: recording,
                        audioRecorder: audioRecorder,
                        onDelete: {
                            deleteRecording(recording)
                        }
                    )
                }
            }
        }
    }

    private var recordingIndicator: some View {
        CardView {
            VStack(spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)

                    Text("Opname loopt...")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(formattedDuration(audioRecorder.recordingDuration))
                        .font(.headline)
                        .foregroundColor(.red)
                }

                // Audio level visualizer
                AudioLevelVisualizer(level: audioRecorder.audioLevel)
            }
        }
    }

    private var recordButton: some View {
        Button(action: {
            toggleRecording()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(audioRecorder.isRecording ? Color.red : Color.accentColor)
                        .frame(width: 80, height: 80)

                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                }

                Text(audioRecorder.isRecording ? "Stop Opname" : "Start Opname")
                    .font(.headline)
                    .foregroundColor(audioRecorder.isRecording ? .red : .accentColor)
            }
        }
    }

    private func toggleRecording() {
        if audioRecorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        _ = audioRecorder.startRecording()
    }

    private func stopRecording() {
        guard let result = audioRecorder.stopRecording() else {
            return
        }

        // Store pending recording and show name dialog
        pendingRecording = result
        recordingName = ""
        showNameDialog = true
    }

    private func saveRecording(name: String) {
        guard let result = pendingRecording else { return }

        // Save audio data
        guard let data = audioRecorder.saveRecording(tempURL: result.url, id: UUID()) else {
            pendingRecording = nil
            return
        }

        let audioId = UUID()
        guard let fileName = MediaStorageService.shared.saveAudioData(data, id: audioId) else {
            pendingRecording = nil
            return
        }

        let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Opname \(audioRecordings.count + 1)"
            : name

        let recording = AudioMedia(
            id: audioId,
            name: finalName,
            duration: result.duration,
            localFileName: fileName,
            sortOrder: audioRecordings.count
        )

        // Link to hike
        recording.hike = viewModel.hike

        modelContext.insert(recording)
        viewModel.hike.updatedAt = Date()

        pendingRecording = nil
        recordingName = ""
    }

    private func deleteRecording(_ recording: AudioMedia) {
        // Delete file from disk
        if let fileName = recording.localFileName {
            MediaStorageService.shared.deleteFile(fileName: fileName, type: .audio)
        }

        modelContext.delete(recording)
        viewModel.hike.updatedAt = Date()
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Level Visualizer

struct AudioLevelVisualizer: View {
    let level: Float

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: index))
                        .frame(width: (geometry.size.width - 76) / 20)
                        .opacity(shouldShowBar(at: index) ? 1.0 : 0.3)
                }
            }
        }
        .frame(height: 30)
    }

    private func shouldShowBar(at index: Int) -> Bool {
        let threshold = Float(index) / 20.0
        return level >= threshold
    }

    private func barColor(for index: Int) -> Color {
        if index < 12 {
            return .green
        } else if index < 16 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Audio Recording Row

struct AudioRecordingRow: View {
    let recording: AudioMedia
    let audioRecorder: AudioRecorderService
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false
    @State private var isCurrentlyPlaying = false

    var isPlaying: Bool {
        isCurrentlyPlaying && audioRecorder.isPlaying
    }

    var body: some View {
        CardView {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "waveform")
                        .font(.title2)
                        .foregroundColor(.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(recording.name)
                            .font(.headline)

                        HStack(spacing: 8) {
                            Text(formattedTimestamp(recording.createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if recording.isUploaded {
                                Image(systemName: "checkmark.icloud")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {
                            togglePlayback()
                        }) {
                            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                        }

                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }

                // Playback progress
                if isPlaying {
                    VStack(spacing: 4) {
                        ProgressView(value: audioRecorder.playbackCurrentTime, total: recording.duration)
                            .tint(.accentColor)

                        HStack {
                            Text(formattedDuration(audioRecorder.playbackCurrentTime))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(formattedDuration(recording.duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Text(recording.formattedDuration)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .confirmationDialog(
            "Opname verwijderen?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Verwijderen", role: .destructive) {
                onDelete()
            }
            Button("Annuleren", role: .cancel) {}
        }
    }

    private func togglePlayback() {
        guard let fileName = recording.localFileName,
              let url = MediaStorageService.shared.getFileURL(for: fileName, type: .audio) else {
            return
        }

        if isPlaying {
            audioRecorder.stopPlaying()
            isCurrentlyPlaying = false
        } else {
            // Stop any other playing audio first
            if audioRecorder.isPlaying {
                audioRecorder.stopPlaying()
            }

            audioRecorder.play(url: url)
            isCurrentlyPlaying = true

            // Auto-stop after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + recording.duration) { [weak audioRecorder] in
                if audioRecorder?.isPlaying == false {
                    isCurrentlyPlaying = false
                }
            }
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Hike.self, AudioMedia.self, configurations: config)

    let hike = Hike(
        status: "inProgress",
        name: "Test Wandeling",
        type: "Dagwandeling",
        startMood: 8
    )

    container.mainContext.insert(hike)

    return AudioTabView(
        viewModel: ActiveHikeViewModel(hike: hike)
    )
    .modelContainer(container)
}
