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

    private let maxPhotos = 5
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var photos: [PhotoMedia] {
        viewModel.hike.photos ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(
                            title: "Foto's",
                            subtitle: "\(photos.count)/\(maxPhotos) foto's"
                        )

                        if photos.isEmpty {
                            Text("Voeg maximaal 5 foto's toe die het verhaal van je wandeling vertellen")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }

                    if photos.isEmpty {
                        emptyState
                    } else {
                        photoGrid
                    }

                    if photos.count < maxPhotos {
                        addPhotoButton
                    }
                }
                .padding()
            }
            .navigationTitle("Foto's")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "photo.on.rectangle.angled",
            title: "Geen foto's",
            message: "Voeg foto's toe om je wandeling vast te leggen"
        )
        .padding(.vertical, 40)
    }

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(photos) { photo in
                PhotoGridItem(photo: photo, onDelete: {
                    deletePhoto(photo)
                })
            }
        }
    }

    private var addPhotoButton: some View {
        VStack(spacing: 12) {
            if photos.count >= maxPhotos {
                Text("Maximaal \(maxPhotos) foto's bereikt")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Button {
                    showImageSourcePicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Foto Toevoegen")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(12)
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
        }
    }

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
    }
}

struct PhotoGridItem: View {
    let photo: PhotoMedia
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false
    @State private var loadedImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // Photo or placeholder
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
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.7))

                                    if photo.isUploaded {
                                        Image(systemName: "checkmark.icloud")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Delete button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(8)
            }

            // Timestamp
            Text(formattedTimestamp(photo.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .onAppear {
            loadImage()
        }
        .confirmationDialog(
            "Foto verwijderen?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Verwijderen", role: .destructive) {
                onDelete()
            }
            Button("Annuleren", role: .cancel) {}
        }
    }

    private func loadImage() {
        guard let fileName = photo.localFileName else { return }
        loadedImage = MediaStorageService.shared.loadImage(fileName: fileName)
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
