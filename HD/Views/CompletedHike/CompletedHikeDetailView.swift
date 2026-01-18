import SwiftUI
import SwiftData

struct CompletedHikeDetailView: View {
    let hike: Hike
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showDeleteConfirmation = false

    var photos: [PhotoMedia] {
        hike.photos ?? []
    }

    var audioRecordings: [AudioMedia] {
        hike.audioRecordings ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header met stats
                statsSection

                // Basis informatie
                basicInfoSection

                // Foto's
                if !photos.isEmpty {
                    photosSection
                }

                // Audio
                if !audioRecordings.isEmpty {
                    audioSection
                }

                // Verhaal en notities
                if !hike.story.isEmpty || !hike.notes.isEmpty {
                    storySection
                }

                // Observaties
                observationsSection

                // Reflectie
                if !hike.reflection.isEmpty {
                    reflectionSection
                }

                // LAW Route info
                if hike.lawRouteName != nil {
                    lawSection
                }

                // Delete button
                deleteButton
            }
            .padding()
        }
        .navigationTitle(hike.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Bewerk") {
                    ActiveHikeView(hike: hike)
                }
            }
        }
        .confirmationDialog(
            "Wandeling verwijderen?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Verwijderen", role: .destructive) {
                deleteHike()
            }
            Button("Annuleren", role: .cancel) {}
        } message: {
            Text("Deze actie kan niet ongedaan worden gemaakt.")
        }
    }

    private var statsSection: some View {
        HStack(spacing: 20) {
            if let distance = hike.distance {
                StatCard(
                    icon: "figure.hiking",
                    title: "Afstand",
                    value: String(format: "%.1f km", distance)
                )
            }

            if let rating = hike.rating {
                StatCard(
                    icon: "star.fill",
                    title: "Waardering",
                    value: "\(rating)/10"
                )
            }

            if let endMood = hike.endMood {
                StatCard(
                    icon: "face.smiling",
                    title: "Eindstemming",
                    value: "\(endMood)/10"
                )
            }
        }
    }

    private var basicInfoSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Informatie",
                subtitle: "Wandeling details"
            )

            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(
                        icon: "figure.walk",
                        label: "Type",
                        value: hike.type
                    )

                    if !hike.companions.isEmpty {
                        DetailRow(
                            icon: "person.2",
                            label: "Gezelschap",
                            value: hike.companions
                        )
                    }

                    DetailRow(
                        icon: "calendar",
                        label: "Datum",
                        value: formattedDate(hike.startTime)
                    )

                    if let endTime = hike.endTime {
                        DetailRow(
                            icon: "clock",
                            label: "Duur",
                            value: formatDuration(from: hike.startTime, to: endTime)
                        )
                    }

                    if let startLocation = hike.startLocationName {
                        DetailRow(
                            icon: "mappin.circle",
                            label: "Start",
                            value: startLocation
                        )
                    }

                    if let endLocation = hike.endLocationName {
                        DetailRow(
                            icon: "mappin.circle.fill",
                            label: "Einde",
                            value: endLocation
                        )
                    }

                    DetailRow(
                        icon: "face.smiling",
                        label: "Startstemming",
                        value: "\(hike.startMood)/10"
                    )
                }
            }
        }
    }

    private var photosSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Foto's",
                subtitle: "\(photos.count) foto('s)"
            )

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(photos) { photo in
                    CompletedPhotoGridItem(photo: photo)
                }
            }
        }
    }

    private var audioSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Audio",
                subtitle: "\(audioRecordings.count) opname(s)"
            )

            VStack(spacing: 12) {
                ForEach(audioRecordings) { recording in
                    CompletedAudioRow(recording: recording)
                }
            }
        }
    }

    private var storySection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Verhaal",
                subtitle: "Jouw wandelverhaal"
            )

            if !hike.story.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verhaal")
                            .font(.headline)

                        Text(hike.story)
                            .font(.body)
                    }
                }
            }

            if !hike.notes.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notities")
                            .font(.headline)

                        Text(hike.notes)
                            .font(.body)
                    }
                }
            }
        }
    }

    private var observationsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Observaties",
                subtitle: "Wat je hebt gezien"
            )

            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    if !hike.terrainDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Terrein")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(hike.terrainDescription)
                                .font(.body)
                        }
                    }

                    if !hike.weatherDescription.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weer")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(hike.weatherDescription)
                                .font(.body)
                        }
                    }

                    Divider()

                    HStack(spacing: 20) {
                        CountBadge(
                            icon: "pawprint",
                            label: "Dieren",
                            count: hike.animalCount
                        )

                        CountBadge(
                            icon: "pause.circle",
                            label: "Pauzes",
                            count: hike.pauseCount
                        )

                        CountBadge(
                            icon: "person.2",
                            label: "Ontmoetingen",
                            count: hike.meetingCount
                        )
                    }
                }
            }
        }
    }

    private var reflectionSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Reflectie",
                subtitle: "Terugblik"
            )

            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(hike.reflection)
                        .font(.body)
                }
            }
        }
    }

    private var lawSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "LAW Route",
                subtitle: "Langeafstandswandeling"
            )

            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    if let routeName = hike.lawRouteName {
                        DetailRow(
                            icon: "signpost.right",
                            label: "Route",
                            value: routeName
                        )
                    }

                    if let stageNumber = hike.lawStageNumber {
                        DetailRow(
                            icon: "number",
                            label: "Etappe",
                            value: "\(stageNumber)"
                        )
                    }
                }
            }
        }
    }

    private var deleteButton: some View {
        SecondaryButton(
            title: "Wandeling Verwijderen",
            action: {
                showDeleteConfirmation = true
            }
        )
        .padding(.top, 20)
    }

    private func deleteHike() {
        modelContext.delete(hike)
        dismiss()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "nl_NL")
        return formatter.string(from: date)
    }

    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)u \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Completed Photo Grid Item

struct CompletedPhotoGridItem: View {
    let photo: PhotoMedia
    @State private var loadedImage: UIImage?

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Group {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                loadImage()
            }
    }

    private func loadImage() {
        guard let fileName = photo.localFileName else { return }
        loadedImage = MediaStorageService.shared.loadImage(fileName: fileName)
    }
}

// MARK: - Completed Audio Row

struct CompletedAudioRow: View {
    let recording: AudioMedia
    @State private var audioRecorder = AudioRecorderService()
    @State private var isPlaying = false

    var body: some View {
        CardView {
            HStack {
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.headline)

                    Text(formattedTimestamp(recording.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(recording.formattedDuration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    private func togglePlayback() {
        guard let fileName = recording.localFileName,
              let url = MediaStorageService.shared.getFileURL(for: fileName, type: .audio) else {
            return
        }

        if isPlaying {
            audioRecorder.stopPlaying()
            isPlaying = false
        } else {
            if audioRecorder.isPlaying {
                audioRecorder.stopPlaying()
            }

            audioRecorder.play(url: url)
            isPlaying = true

            DispatchQueue.main.asyncAfter(deadline: .now() + recording.duration) {
                isPlaying = false
            }
        }
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

struct CountBadge: View {
    let icon: String
    let label: String
    let count: Int

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text("\(count)")
                    .font(.headline)
            }
            .foregroundColor(.primary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        CompletedHikeDetailView(
            hike: Hike(
                status: "completed",
                name: "Pieterpad Etappe 1",
                type: "Meerdaagse wandeling",
                companions: "Jan, Marie",
                startLocationName: "Pieterburen",
                startTime: Date().addingTimeInterval(-86400),
                startMood: 8,
                story: "Een prachtige dag om te wandelen. Het weer was perfect en het gezelschap geweldig.",
                terrainDescription: "Gevarieerd terrein met bossen en heidevelden",
                weatherDescription: "Zonnig met een enkele wolk, lichte wind",
                notes: "Vergeet volgende keer geen zonnebrand!",
                animalCount: 5,
                pauseCount: 3,
                meetingCount: 2,
                endTime: Date(),
                distance: 24.5,
                rating: 9,
                endLocationName: "Groningen",
                endMood: 9,
                reflection: "Een fantastische eerste etappe. Kan niet wachten op de volgende!",
                lawRouteName: "Pieterpad",
                lawStageNumber: 1
            )
        )
    }
}
