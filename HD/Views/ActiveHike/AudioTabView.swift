import SwiftUI
import SwiftData

struct AudioTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var audioRecorder = AudioRecorderService()
    @State private var showSaveSheet = false
    @State private var recordingName = ""
    @State private var pendingRecording: (url: URL, duration: TimeInterval)?
    @State private var pulseScale: CGFloat = 1.0

    var audioRecordings: [AudioMedia] {
        viewModel.hike.audioRecordings ?? []
    }

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Recording indicator card (shown at top when recording)
                if audioRecorder.isRecording {
                    recordingCard
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.md)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Recordings list card
                if audioRecordings.isEmpty && !audioRecorder.isRecording {
                    emptyState
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.lg)
                } else if !audioRecordings.isEmpty {
                    recordingsCard
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.md)
                }

                Spacer()

                // Record button section at bottom
                recordButtonSection
                    .padding(.bottom, HDSpacing.lg)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: audioRecorder.isRecording)
        .sheet(isPresented: $showSaveSheet) {
            SaveRecordingSheet(
                recordingName: $recordingName,
                duration: pendingRecording?.duration ?? 0,
                onSave: { name in
                    saveRecording(name: name)
                    showSaveSheet = false
                },
                onCancel: {
                    if let pending = pendingRecording {
                        try? FileManager.default.removeItem(at: pending.url)
                    }
                    pendingRecording = nil
                    recordingName = ""
                    showSaveSheet = false
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HDSpacing.md) {
            // Icon in circle
            ZStack {
                Circle()
                    .fill(HDColors.sageGreen.opacity(0.3))
                    .frame(width: 80, height: 80)

                Image(systemName: "waveform")
                    .font(.system(size: 32))
                    .foregroundColor(HDColors.forestGreen)
            }

            VStack(spacing: HDSpacing.xs) {
                Text("Geen opnames")
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)

                Text("Tik op de microfoon om een audio notitie op te nemen")
                    .font(.subheadline)
                    .foregroundColor(HDColors.mutedGreen)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HDSpacing.xl)
    }

    // MARK: - Recording Card (Active Recording)

    private var recordingCard: some View {
        VStack(spacing: HDSpacing.sm) {
            HStack {
                // Pulsing red dot
                ZStack {
                    Circle()
                        .fill(HDColors.recordingRed.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .scaleEffect(pulseScale)

                    Circle()
                        .fill(HDColors.recordingRed)
                        .frame(width: 10, height: 10)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        pulseScale = 1.5
                    }
                }

                Text("Opname")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(HDColors.forestGreen)

                Spacer()

                Text(formattedDuration(audioRecorder.recordingDuration))
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .foregroundColor(HDColors.forestGreen)
            }

            // Elegant waveform
            AudioWaveformView(level: audioRecorder.audioLevel)
        }
        .padding(HDSpacing.md)
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Recordings Card

    private var recordingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: HDSpacing.xs) {
                Image(systemName: "waveform")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen)
                Text("OPNAMES")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen)
                    .tracking(0.5)

                Spacer()

                Text("\(audioRecordings.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(HDColors.mutedGreen)
                    .padding(.horizontal, HDSpacing.xs)
                    .padding(.vertical, 4)
                    .background(HDColors.sageGreen.opacity(0.5))
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
            }
            .padding(.horizontal, HDSpacing.md)
            .padding(.top, HDSpacing.md)
            .padding(.bottom, HDSpacing.sm)

            // Recording rows with notebook background
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(audioRecordings) { recording in
                        recordingRow(recording)

                        if recording.id != audioRecordings.last?.id {
                            Divider()
                                .background(HDColors.dividerColor.opacity(0.3))
                                .padding(.horizontal, HDSpacing.md)
                        }
                    }
                }
            }
            .background(
                ZStack {
                    HDColors.cardBackground
                    NotebookLinesBackground(lineSpacing: 52)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium))
        }
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Recording Row

    private func recordingRow(_ recording: AudioMedia) -> some View {
        AudioRecordingRow(
            recording: recording,
            audioRecorder: audioRecorder,
            onDelete: {
                deleteRecording(recording)
            }
        )
    }

    // MARK: - Record Button Section

    private var recordButtonSection: some View {
        VStack(spacing: HDSpacing.sm) {
            RecordButton(isRecording: audioRecorder.isRecording) {
                toggleRecording()
            }

            Text(audioRecorder.isRecording ? "Tik om te stoppen" : "Tik om op te nemen")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)
        }
    }

    // MARK: - Actions

    private func toggleRecording() {
        if audioRecorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        pulseScale = 1.0
        _ = audioRecorder.startRecording()
    }

    private func stopRecording() {
        guard let result = audioRecorder.stopRecording() else {
            return
        }

        pendingRecording = result
        recordingName = ""
        showSaveSheet = true
    }

    private func saveRecording(name: String) {
        guard let result = pendingRecording else { return }

        guard let data = audioRecorder.saveRecording(tempURL: result.url, id: UUID()) else {
            pendingRecording = nil
            return
        }

        let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Opname \(audioRecordings.count + 1)"
            : name

        let recording = AudioMedia(
            name: finalName,
            duration: result.duration,
            audioData: data,
            sortOrder: audioRecordings.count
        )

        recording.hike = viewModel.hike
        modelContext.insert(recording)
        viewModel.hike.updatedAt = Date()

        pendingRecording = nil
        recordingName = ""
    }

    private func deleteRecording(_ recording: AudioMedia) {
        modelContext.delete(recording)
        viewModel.hike.updatedAt = Date()
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Save Recording Sheet

struct SaveRecordingSheet: View {
    @Binding var recordingName: String
    let duration: TimeInterval
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            // Header
            VStack(spacing: HDSpacing.xs) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(HDColors.forestGreen)

                Text("Opname opslaan")
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)

                Text(formattedDuration(duration))
                    .font(.caption)
                    .foregroundColor(HDColors.mutedGreen)
            }

            // Name field
            HDTextField(
                "Naam (optioneel)",
                text: $recordingName
            )

            // Buttons
            VStack(spacing: HDSpacing.sm) {
                PrimaryButton(title: "Opslaan") {
                    onSave(recordingName)
                }

                Button("Standaard naam gebruiken") {
                    onSave("")
                }
                .font(.subheadline)
                .foregroundColor(HDColors.forestGreen)

                Button("Annuleren") {
                    onCancel()
                }
                .font(.subheadline)
                .foregroundColor(HDColors.mutedGreen)
            }
        }
        .padding(HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(HDColors.cream)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Delete Confirmation Sheet

struct DeleteConfirmationSheet: View {
    let recordingName: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            // Warning icon
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(HDColors.recordingRed)

            VStack(spacing: HDSpacing.xs) {
                Text("Opname verwijderen?")
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)

                Text(recordingName)
                    .font(.subheadline)
                    .foregroundColor(HDColors.mutedGreen)
            }

            // Buttons
            VStack(spacing: HDSpacing.sm) {
                Button(action: onDelete) {
                    Text("Verwijderen")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HDSpacing.md)
                        .background(HDColors.recordingRed)
                        .cornerRadius(HDSpacing.cornerRadiusMedium)
                }

                Button("Annuleren") {
                    onCancel()
                }
                .font(.subheadline)
                .foregroundColor(HDColors.forestGreen)
            }
        }
        .padding(HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(HDColors.cream)
    }
}

// MARK: - Audio Recording Row

struct AudioRecordingRow: View {
    let recording: AudioMedia
    let audioRecorder: AudioRecorderService
    let onDelete: () -> Void

    @State private var showDeleteSheet = false
    @State private var isCurrentlyPlaying = false
    @State private var playbackProgress: Double = 0
    @State private var playbackTimer: Timer?

    var isPlaying: Bool {
        isCurrentlyPlaying && audioRecorder.isPlaying
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: HDSpacing.sm) {
                // Waveform icon in circle
                ZStack {
                    Circle()
                        .fill(HDColors.sageGreen.opacity(0.3))
                        .frame(width: 40, height: 40)

                    if isPlaying {
                        // Animated waveform when playing
                        PlayingWaveformIcon()
                    } else {
                        StaticWaveformIcon(
                            barCount: 5,
                            barWidth: 2,
                            barSpacing: 1.5,
                            maxHeight: 16,
                            color: HDColors.forestGreen
                        )
                    }
                }

                // Name and timestamp
                VStack(alignment: .leading, spacing: 2) {
                    Text(recording.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(HDColors.forestGreen)
                        .lineLimit(1)

                    Text(formattedTimestamp(recording.createdAt))
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen)
                }

                Spacer()

                // Duration
                Text(recording.formattedDuration)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(HDColors.mutedGreen)
                    .padding(.trailing, HDSpacing.xs)

                // Play/Stop button
                Button(action: togglePlayback) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? HDColors.forestGreen : HDColors.sageGreen.opacity(0.5))
                            .frame(width: 36, height: 36)

                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isPlaying ? .white : HDColors.forestGreen)
                    }
                }
                .buttonStyle(.plain)

                // Delete button
                Button(action: { showDeleteSheet = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(HDColors.mutedGreen)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
            }

            // Playback progress bar (shown when playing)
            if isPlaying {
                HStack(spacing: HDSpacing.xs) {
                    Text(formattedDuration(playbackProgress * recording.duration))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(HDColors.mutedGreen)
                        .frame(width: 36, alignment: .leading)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(HDColors.sageGreen.opacity(0.3))
                                .frame(height: 4)

                            Capsule()
                                .fill(HDColors.forestGreen)
                                .frame(width: geo.size.width * playbackProgress, height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text(recording.formattedDuration)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(HDColors.mutedGreen)
                        .frame(width: 36, alignment: .trailing)
                }
                .padding(.top, HDSpacing.xs)
                .padding(.leading, 48) // Align with text after icon
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, HDSpacing.md)
        .padding(.vertical, HDSpacing.sm)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
        .sheet(isPresented: $showDeleteSheet) {
            DeleteConfirmationSheet(
                recordingName: recording.name,
                onDelete: {
                    onDelete()
                    showDeleteSheet = false
                },
                onCancel: {
                    showDeleteSheet = false
                }
            )
            .presentationDetents([.height(240)])
            .presentationDragIndicator(.visible)
        }
        .onDisappear {
            stopPlaybackTimer()
        }
    }

    private func togglePlayback() {
        guard let url = recording.temporaryFileURL else {
            return
        }

        if isPlaying {
            audioRecorder.stopPlaying()
            isCurrentlyPlaying = false
            stopPlaybackTimer()
            playbackProgress = 0
        } else {
            if audioRecorder.isPlaying {
                audioRecorder.stopPlaying()
            }

            audioRecorder.play(url: url)
            isCurrentlyPlaying = true
            playbackProgress = 0
            startPlaybackTimer()
        }
    }

    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if audioRecorder.isPlaying {
                let currentTime = audioRecorder.playbackCurrentTime
                playbackProgress = min(1.0, currentTime / recording.duration)
            } else {
                // Playback finished
                isCurrentlyPlaying = false
                stopPlaybackTimer()
                playbackProgress = 0
            }
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Playing Waveform Icon (Animated)

struct PlayingWaveformIcon: View {
    @State private var animationPhase: Double = 0

    private let barCount = 5
    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 1.5
    private let maxHeight: CGFloat = 16

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(HDColors.forestGreen)
                    .frame(width: barWidth, height: barHeight(for: index))
            }
        }
        .frame(height: maxHeight)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                animationPhase = 1
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let baseHeights: [CGFloat] = [0.4, 0.7, 1.0, 0.7, 0.4]
        let animationOffsets: [CGFloat] = [0.3, -0.2, 0.3, -0.2, 0.3]

        let base = baseHeights[index % baseHeights.count]
        let offset = animationOffsets[index % animationOffsets.count] * CGFloat(animationPhase)

        return maxHeight * max(0.2, min(1.0, base + offset))
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
