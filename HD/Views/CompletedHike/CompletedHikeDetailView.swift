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
        ZStack {
            HDColors.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HDSpacing.lg) {
                    // Hero header met naam en rating
                    heroHeader

                    // Header met stats
                    statsSection

                    // Basis informatie
                    basicInfoSection

                    // De Reis (start → eind met stemmingen)
                    journeySection

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

                    // Delete button
                    deleteButton
                }
                .padding(.horizontal, HDSpacing.horizontalMargin)
                .padding(.top, HDSpacing.md)
                .padding(.bottom, HDSpacing.xl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(HDColors.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(.light)
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

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            HStack {
                Text(hike.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(HDColors.forestGreen)

                Spacer()

                // Rating badge met amber accent
                if let rating = hike.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(HDColors.amber)
                        Text("\(rating)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, HDSpacing.sm)
                    .padding(.vertical, HDSpacing.xs)
                    .background(HDColors.amberLight.opacity(0.5))
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
            }

            // Datum subtitel
            Text(formattedDate(hike.startTime))
                .font(.subheadline)
                .foregroundColor(HDColors.mutedGreen)
        }
    }

    private var statsSection: some View {
        HStack(spacing: HDSpacing.md) {
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
                    value: "\(rating)/10",
                    isHighlighted: rating >= 8
                )
            }

            if let endTime = hike.endTime {
                StatCard(
                    icon: "clock",
                    title: "Duur",
                    value: formatDuration(from: hike.startTime, to: endTime)
                )
            }
        }
    }

    private var basicInfoSection: some View {
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Informatie",
                subtitle: "Wandeling details"
            )

            CardView {
                VStack(alignment: .leading, spacing: HDSpacing.sm) {
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

                    // LAW Route info (indien aanwezig)
                    if hike.lawRouteName != nil {
                        Divider()

                        if let routeName = hike.lawRouteName {
                            DetailRow(
                                icon: "signpost.right",
                                label: "LAW Route",
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
    }

    private var photosSection: some View {
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Foto's",
                subtitle: "\(photos.count) foto('s)"
            )

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: HDSpacing.sm
            ) {
                ForEach(photos) { photo in
                    CompletedPhotoGridItem(photo: photo)
                }
            }
        }
    }

    private var audioSection: some View {
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Audio",
                subtitle: "\(audioRecordings.count) opname(s)"
            )

            VStack(spacing: HDSpacing.sm) {
                ForEach(audioRecordings) { recording in
                    CompletedAudioRow(recording: recording)
                }
            }
        }
    }

    private var storySection: some View {
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Verhaal",
                subtitle: "Jouw wandelverhaal"
            )

            if !hike.story.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: HDSpacing.xs) {
                        Text("Verhaal")
                            .font(.headline)

                        Text(hike.story)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if !hike.notes.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: HDSpacing.xs) {
                        Text("Notities")
                            .font(.headline)

                        Text(hike.notes)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var observationsSection: some View {
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Observaties",
                subtitle: "Wat je hebt gezien"
            )

            CardView {
                VStack(alignment: .leading, spacing: HDSpacing.sm) {
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

                    HStack(spacing: HDSpacing.lg) {
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
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Reflectie",
                subtitle: "Terugblik"
            )

            CardView {
                VStack(alignment: .leading, spacing: HDSpacing.xs) {
                    Text(hike.reflection)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var journeySection: some View {
        VStack(spacing: HDSpacing.sm) {
            SectionHeader(
                title: "De Reis",
                subtitle: "Van start tot eind"
            )

            JourneyCard(
                startLocation: hike.startLocationName,
                startTime: hike.startTime,
                startMood: hike.startMood,
                endLocation: hike.endLocationName,
                endTime: hike.endTime,
                endMood: hike.endMood
            )
        }
    }

    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Wandeling Verwijderen")
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(HDColors.recordingRed)
            .frame(maxWidth: .infinity)
            .padding(HDSpacing.buttonPadding)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium)
                    .stroke(HDColors.recordingRed, lineWidth: 2)
            )
        }
        .padding(.top, HDSpacing.xl)
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
        RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium)
            .fill(
                LinearGradient(
                    colors: [HDColors.sageGreen.opacity(0.3), HDColors.sageGreen.opacity(0.1)],
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
                            .foregroundColor(HDColors.mutedGreen.opacity(0.5))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium))
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
                    .foregroundColor(HDColors.forestGreen)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.headline)

                    Text(formattedTimestamp(recording.createdAt))
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen)
                }

                Spacer()

                Text(recording.formattedDuration)
                    .font(.subheadline)
                    .foregroundColor(HDColors.mutedGreen)

                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(HDColors.forestGreen)
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
    var isHighlighted: Bool = false

    var body: some View {
        VStack(spacing: HDSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isHighlighted ? HDColors.amber : HDColors.forestGreen)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(HDColors.forestGreen)

            Text(title)
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(HDSpacing.cardPadding)
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(HDColors.mutedGreen)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(HDColors.mutedGreen)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(HDColors.forestGreen)
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
            .foregroundColor(HDColors.forestGreen)

            Text(label)
                .font(.caption2)
                .foregroundColor(HDColors.mutedGreen)
        }
        .padding(.horizontal, HDSpacing.sm)
        .padding(.vertical, HDSpacing.xs)
        .background(HDColors.sageGreen.opacity(0.2))
        .cornerRadius(HDSpacing.cornerRadiusSmall)
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
    .preferredColorScheme(.light)
}
