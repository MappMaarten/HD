import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Query private var hikes: [Hike]
    @State private var selectedHike: Hike?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                map

                if let selectedHike = selectedHike {
                    hikeInfoCard
                }
            }
            .navigationTitle("Kaart")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var map: some View {
        Map(position: $cameraPosition) {
            ForEach(hikesWithLocation) { hike in
                Annotation(
                    hike.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: hike.startLatitude ?? 0,
                        longitude: hike.startLongitude ?? 0
                    )
                ) {
                    MapMarker(
                        hike: hike,
                        isSelected: selectedHike?.id == hike.id,
                        onTap: {
                            selectedHike = hike
                        }
                    )
                }
            }
        }
        .mapStyle(.standard)
        .onTapGesture {
            selectedHike = nil
        }
    }

    private var hikeInfoCard: some View {
        HikeInfoCard(
            hike: selectedHike!,
            onClose: {
                selectedHike = nil
            }
        )
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: selectedHike)
    }

    private var hikesWithLocation: [Hike] {
        hikes.filter { hike in
            hike.startLatitude != nil && hike.startLongitude != nil
        }
    }
}

struct MapMarker: View {
    let hike: Hike
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(markerColor)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                    .shadow(color: .black.opacity(0.3), radius: 4)

                Image(systemName: "figure.hiking")
                    .font(.system(size: isSelected ? 24 : 20))
                    .foregroundColor(.white)
            }
        }
        .animation(.spring(), value: isSelected)
    }

    private var markerColor: Color {
        if hike.status == "inProgress" {
            return .green
        } else {
            return .accentColor
        }
    }
}

struct HikeInfoCard: View {
    let hike: Hike
    let onClose: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hike.name)
                            .font(.headline)

                        Text(hike.type)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                HStack(spacing: 16) {
                    if let location = hike.startLocationName {
                        InfoItem(
                            icon: "mappin.circle",
                            text: location
                        )
                    }

                    if hike.status == "completed", let distance = hike.distance {
                        InfoItem(
                            icon: "figure.hiking",
                            text: String(format: "%.1f km", distance)
                        )
                    }

                    if hike.status == "completed", let rating = hike.rating {
                        InfoItem(
                            icon: "star.fill",
                            text: "\(rating)/10"
                        )
                    }
                }

                if hike.status == "inProgress" {
                    HStack {
                        Image(systemName: "record.circle")
                            .foregroundColor(.green)
                        Text("Actieve wandeling")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }

                // Placeholder voor detail navigatie
                Button(action: {
                    // Later: Navigate to detail view
                }) {
                    Text("Bekijk Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct InfoItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MapView()
        .modelContainer(for: Hike.self, inMemory: true)
}

#Preview("With Hikes") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Hike.self, configurations: config)

    let hike1 = Hike(
        status: "completed",
        name: "Wandeling Amsterdam",
        type: "Stadswandeling",
        startLatitude: 52.3676,
        startLongitude: 4.9041,
        startLocationName: "Amsterdam Centrum",
        startTime: Date().addingTimeInterval(-86400),
        startMood: 8,
        distance: 12.5,
        rating: 9
    )

    let hike2 = Hike(
        status: "inProgress",
        name: "Bos wandeling",
        type: "Boswandeling",
        startLatitude: 52.0907,
        startLongitude: 5.1214,
        startLocationName: "Utrecht",
        startTime: Date(),
        startMood: 7
    )

    container.mainContext.insert(hike1)
    container.mainContext.insert(hike2)

    return MapView()
        .modelContainer(container)
}
