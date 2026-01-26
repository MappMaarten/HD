import SwiftUI
import SwiftData
import PhotosUI

struct PhotosTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showImageSourcePicker = false
    @State private var showCameraPicker = false
    @State private var showPhotoPicker = false
    @State private var photoToDelete: PhotoMedia?
    @State private var showDeleteSheet = false

    private let maxPhotos = 5

    var photos: [PhotoMedia] {
        (viewModel.hike.photos ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Photo story card or empty state
                if photos.isEmpty {
                    emptyState
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.lg)
                } else {
                    photoStorySlotsCard
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.md)
                }

                Spacer()

                // Add photo button section at bottom
                photoButtonSection
                    .padding(.bottom, HDSpacing.lg)
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await addPhotos(from: newItems)
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraImagePicker { image in
                if let image = image {
                    Task {
                        await addPhoto(image: image)
                    }
                }
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedItems,
            maxSelectionCount: maxPhotos - photos.count,
            matching: .images
        )
        .sheet(isPresented: $showDeleteSheet) {
            if let photo = photoToDelete {
                PhotoDeleteConfirmationSheet(
                    photoIndex: (photos.firstIndex(where: { $0.id == photo.id }) ?? 0) + 1,
                    photo: photo,
                    onDelete: {
                        deletePhoto(photo)
                        photoToDelete = nil
                        showDeleteSheet = false
                    },
                    onCancel: {
                        photoToDelete = nil
                        showDeleteSheet = false
                    }
                )
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
            }
        }
        .confirmationDialog("Foto toevoegen", isPresented: $showImageSourcePicker) {
            Button("Camera") {
                showCameraPicker = true
            }

            Button("Kies uit bibliotheek") {
                showPhotoPicker = true
            }

            Button("Annuleer", role: .cancel) {}
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

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 32))
                    .foregroundColor(HDColors.forestGreen)
            }

            VStack(spacing: HDSpacing.xs) {
                Text("Vertel je verhaal in foto's")
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)

                Text("Kies 5 foto's die het beste het verhaal van je wandeling vertellen")
                    .font(.subheadline)
                    .foregroundColor(HDColors.mutedGreen)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HDSpacing.xl)
    }

    // MARK: - Photo Story Slots Card

    private var photoStorySlotsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: HDSpacing.xs) {
                Image(systemName: "photo.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen)
                Text("VERHAAL")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen)
                    .tracking(0.5)

                Spacer()

                Text("\(photos.count)/\(maxPhotos)")
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

            // Photo slots grid
            photoSlotsGrid
                .padding(.horizontal, HDSpacing.md)
                .padding(.bottom, HDSpacing.md)

            // Progress bar
            progressSection
                .padding(.horizontal, HDSpacing.md)
                .padding(.bottom, HDSpacing.md)
        }
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Photo Slots Grid

    private var photoSlotsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: HDSpacing.sm),
            GridItem(.flexible(), spacing: HDSpacing.sm),
            GridItem(.flexible(), spacing: HDSpacing.sm)
        ]

        return LazyVGrid(columns: columns, spacing: HDSpacing.sm) {
            ForEach(0..<maxPhotos, id: \.self) { index in
                if index < photos.count {
                    PhotoSlotFilled(
                        photo: photos[index],
                        slotNumber: index + 1,
                        onDelete: {
                            photoToDelete = photos[index]
                            showDeleteSheet = true
                        }
                    )
                } else {
                    PhotoSlotEmpty(
                        slotNumber: index + 1,
                        isNextSlot: index == photos.count,
                        onTap: {
                            showImageSourcePicker = true
                        }
                    )
                }
            }
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: HDSpacing.xs) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HDColors.sageGreen.opacity(0.3))
                        .frame(height: 6)

                    Capsule()
                        .fill(photos.count == maxPhotos ? HDColors.forestGreen : HDColors.amber)
                        .frame(width: geo.size.width * CGFloat(photos.count) / CGFloat(maxPhotos), height: 6)
                }
            }
            .frame(height: 6)

            // Completion message
            if photos.count == maxPhotos {
                HStack(spacing: HDSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(HDColors.forestGreen)
                    Text("Verhaal compleet!")
                        .font(.caption.weight(.medium))
                        .foregroundColor(HDColors.forestGreen)
                }
                .padding(.top, HDSpacing.xs)
            }
        }
    }

    // MARK: - Photo Button Section

    private var photoButtonSection: some View {
        VStack(spacing: HDSpacing.sm) {
            PhotoAddButton(
                action: { showImageSourcePicker = true },
                isDisabled: photos.count >= maxPhotos
            )

            Text(photos.count >= maxPhotos ? "Verhaal compleet" : "Tik om foto toe te voegen")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)
        }
    }

    // MARK: - Actions

    @MainActor
    private func addPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            guard photos.count < maxPhotos else { break }

            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await addPhoto(image: uiImage)
            }
        }

        // Reset picker
        selectedItems = []
    }

    @MainActor
    private func addPhoto(image: UIImage) async {
        guard photos.count < maxPhotos else { return }

        let photoId = UUID()

        // Save image to disk
        guard let fileName = MediaStorageService.shared.saveImage(image, id: photoId) else {
            return
        }

        let photo = PhotoMedia(
            id: photoId,
            localFileName: fileName,
            sortOrder: photos.count
        )

        // Link photo to hike
        photo.hike = viewModel.hike

        modelContext.insert(photo)
        viewModel.hike.updatedAt = Date()
    }

    private func deletePhoto(_ photo: PhotoMedia) {
        // Delete file from disk
        if let fileName = photo.localFileName {
            MediaStorageService.shared.deleteFile(fileName: fileName, type: .photos)
        }

        modelContext.delete(photo)
        viewModel.hike.updatedAt = Date()

        // Re-order remaining photos
        Task { @MainActor in
            for (index, remainingPhoto) in photos.enumerated() {
                remainingPhoto.sortOrder = index
            }
        }
    }
}

// MARK: - Photo Slot Empty

struct PhotoSlotEmpty: View {
    let slotNumber: Int
    let isNextSlot: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                    .strokeBorder(
                        isNextSlot ? HDColors.forestGreen : HDColors.dividerColor,
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                            .fill(isNextSlot ? HDColors.sageGreen.opacity(0.2) : Color.clear)
                    )
                    .aspectRatio(1, contentMode: .fit)

                VStack(spacing: 4) {
                    if isNextSlot {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(HDColors.forestGreen)
                    }

                    Text("\(slotNumber)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(isNextSlot ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.6))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Photo Slot Filled

struct PhotoSlotFilled: View {
    let photo: PhotoMedia
    let slotNumber: Int
    let onDelete: () -> Void

    @State private var loadedImage: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Photo container
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                    .fill(HDColors.sageGreen.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Group {
                            if let image = loadedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(HDColors.mutedGreen.opacity(0.5))
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall))

                // Slot number badge
                Text("\(slotNumber)")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(HDColors.forestGreen)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 18, height: 18)
                    )
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: -4)
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let fileName = photo.localFileName else { return }
        loadedImage = MediaStorageService.shared.loadImage(fileName: fileName)
    }
}

// MARK: - Photo Delete Confirmation Sheet

struct PhotoDeleteConfirmationSheet: View {
    let photoIndex: Int
    let photo: PhotoMedia
    let onDelete: () -> Void
    let onCancel: () -> Void

    @State private var loadedImage: UIImage?

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            // Photo thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium)
                    .fill(HDColors.sageGreen.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Group {
                            if let image = loadedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(HDColors.mutedGreen.opacity(0.5))
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium))

                // Slot number badge
                Text("\(photoIndex)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(HDColors.forestGreen)
                    .clipShape(Circle())
                    .offset(x: -44, y: 44)
            }

            VStack(spacing: HDSpacing.xs) {
                Text("Foto verwijderen?")
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)

                Text("Foto \(photoIndex) van je verhaal")
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
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let fileName = photo.localFileName else { return }
        loadedImage = MediaStorageService.shared.loadImage(fileName: fileName)
    }
}

// MARK: - Camera Image Picker

struct CameraImagePicker: UIViewControllerRepresentable {
    let completion: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker

        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.completion(image)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            parent.dismiss()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Hike.self, PhotoMedia.self, configurations: config)

    let hike = Hike(
        status: "inProgress",
        name: "Test Wandeling",
        type: "Dagwandeling",
        startMood: 8
    )

    container.mainContext.insert(hike)

    return PhotosTabView(
        viewModel: ActiveHikeViewModel(hike: hike)
    )
    .modelContainer(container)
}
