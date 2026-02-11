import SwiftUI
import SwiftData

struct CompletedHikeDetailView: View {
    let hike: Hike
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showDeleteConfirmation = false
    @State private var audioRecorder = AudioRecorderService()
    @State private var selectedPhotoIndex: Int?

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
                    heroHeader

                    statsSection

                    basicInfoSection

                    journeySection

                    // Verhaal
                    if !hike.story.isEmpty {
                        storySection
                    }

                    // Observaties
                    observationsSection

                    // Audio
                    if !audioRecordings.isEmpty {
                        audioSection
                    }

                    // Foto's
                    if !photos.isEmpty {
                        photosSection
                    }

                    // Reflectie
                    if !hike.reflection.isEmpty {
                        reflectionSection
                    }

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
        .sheet(isPresented: $showDeleteConfirmation) {
            VStack(spacing: HDSpacing.lg) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundColor(HDColors.recordingRed)
                    .frame(width: 64, height: 64)
                    .background(HDColors.recordingRed.opacity(0.1))
                    .clipShape(Circle())

                VStack(spacing: HDSpacing.xs) {
                    Text("Wandeling verwijderen?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(HDColors.forestGreen)

                    Text("Deze actie kan niet ongedaan worden gemaakt. Alle gegevens, foto's en audio worden definitief verwijderd.")
                        .font(.subheadline)
                        .foregroundColor(HDColors.mutedGreen)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: HDSpacing.sm) {
                    Button {
                        showDeleteConfirmation = false
                        deleteHike()
                    } label: {
                        Text("Verwijderen")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(HDSpacing.buttonPadding)
                            .background(HDColors.recordingRed)
                            .cornerRadius(HDSpacing.cornerRadiusMedium)
                    }

                    Button {
                        showDeleteConfirmation = false
                    } label: {
                        Text("Annuleren")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(HDColors.mutedGreen)
                            .frame(maxWidth: .infinity)
                            .padding(HDSpacing.buttonPadding)
                            .background(HDColors.sageGreen.opacity(0.2))
                            .cornerRadius(HDSpacing.cornerRadiusMedium)
                    }
                }
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.top, HDSpacing.xl)
            .padding(.bottom, HDSpacing.lg)
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationBackground(HDColors.cream)
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text(hike.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(HDColors.forestGreen)

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
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    CompletedPhotoGridItem(photo: photo)
                        .onTapGesture {
                            selectedPhotoIndex = index
                        }
                }
            }
        }
        .fullScreenCover(item: Binding<PhotoIndex?>(
            get: {
                if let index = selectedPhotoIndex {
                    return PhotoIndex(index: index)
                }
                return nil
            },
            set: { newValue in
                selectedPhotoIndex = newValue?.index
            }
        )) { item in
            FullScreenPhotoView(photos: photos, initialIndex: item.index)
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
                    CompletedAudioRow(recording: recording, audioRecorder: audioRecorder)
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

                    HStack(spacing: HDSpacing.sm) {
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

                    if !hike.notes.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bijzondere observaties")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(hike.notes)
                                .font(.body)
                        }
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
        formatter.timeStyle = .none
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
        loadedImage = photo.image
    }
}

// MARK: - Completed Audio Row

struct CompletedAudioRow: View {
    let recording: AudioMedia
    let audioRecorder: AudioRecorderService

    @State private var isCurrentlyPlaying = false
    @State private var playbackProgress: Double = 0
    @State private var playbackTimer: Timer?

    var isPlaying: Bool {
        isCurrentlyPlaying && audioRecorder.isPlaying && audioRecorder.playingURL == recording.temporaryFileURL
    }

    var body: some View {
        CardView {
            VStack(spacing: 0) {
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

                // Playback progress bar (shown when playing)
                if isPlaying {
                    HStack(spacing: HDSpacing.xs) {
                        Text(formattedDuration(playbackProgress * recording.duration))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(HDColors.mutedGreen)
                            .frame(width: 36, alignment: .leading)

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
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isPlaying)
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
            if audioRecorder.isPlaying && audioRecorder.playingURL == recording.temporaryFileURL {
                let currentTime = audioRecorder.playbackCurrentTime
                playbackProgress = min(1.0, currentTime / recording.duration)
            } else {
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HDSpacing.xs)
        .background(HDColors.sageGreen.opacity(0.2))
        .cornerRadius(HDSpacing.cornerRadiusSmall)
    }
}

// MARK: - Photo Index (Identifiable wrapper for fullScreenCover)

private struct PhotoIndex: Identifiable {
    let index: Int
    var id: Int { index }
}

// MARK: - Full Screen Photo View

struct FullScreenPhotoView: View {
    let photos: [PhotoMedia]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @State private var magnification: CGFloat = 1.0

    init(photos: [PhotoMedia], initialIndex: Int) {
        self.photos = photos
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    ZoomablePhotoPage(photo: photo)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .automatic : .never))

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, HDSpacing.md)
                    .padding(.top, HDSpacing.sm)
                }
                Spacer()
            }
        }
        .statusBarHidden(true)
    }
}

// MARK: - Zoomable Photo Page

private struct ZoomablePhotoPage: View {
    let photo: PhotoMedia
    @State private var loadedImage: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { value in
                                lastScale = scale
                                if scale < 1.0 {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                } else if scale > 4.0 {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        scale = 4.0
                                        lastScale = 4.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .onAppear {
            loadedImage = photo.image
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
    .preferredColorScheme(.light)
}
