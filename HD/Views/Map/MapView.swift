import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Query private var hikes: [Hike]
    @Query(sort: \HikeType.sortOrder) private var hikeTypes: [HikeType]
    @Environment(\.dismiss) private var dismiss

    @State private var selectedHike: Hike?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.1326, longitude: 5.2913), // Netherlands center
            span: MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5)
        )
    )

    // Info popup state
    @State private var showInfoPopup: Bool = false
    @AppStorage("hasSeenMapInfoPopup") private var hasSeenMapInfoPopup: Bool = false

    // Filter state
    @State private var showFilterSheet: Bool = false
    @State private var selectedTypeFilters: Set<String> = []
    @State private var selectedTimePeriod: TimePeriod = .all

    // Map style state
    @State private var usesSatelliteMap: Bool = false

    // Navigation state
    @State private var navigateToHike: Hike?

    // Computed property for current map style
    private var currentMapStyle: MapStyle {
        usesSatelliteMap ? .imagery : .standard
    }

    var body: some View {
        NavigationStack {
            ZStack {
                map

                // Top buttons (ListMapToggle left, satellite + info right)
                VStack {
                    HStack {
                        // List/Map toggle - tapping list dismisses to overview
                        ListMapToggle(showMap: Binding(
                            get: { true },
                            set: { newValue in
                                if !newValue { dismiss() }
                            }
                        ))

                        Spacer()

                        // Satellite toggle button
                        CircularButton(
                            icon: usesSatelliteMap ? "map" : "globe.europe.africa",
                            action: {
                                withAnimation(.easeInOut) {
                                    usesSatelliteMap.toggle()
                                }
                            },
                            size: 40,
                            style: .secondary
                        )

                        // Info button
                        CircularButton(icon: "info", action: {
                            showInfoPopup = true
                        }, size: 40, style: .secondary)
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.top, HDSpacing.sm)

                    Spacer()
                }

                // Filter FAB (bottom right) - fixed position
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        filterFAB
                    }
                    .padding(.trailing, HDSpacing.fabMargin)
                    .padding(.bottom, HDSpacing.fabMargin)
                }

                // Selected hike info card
                if selectedHike != nil {
                    VStack {
                        Spacer()
                        hikeInfoCard
                    }
                }

                // Info popup overlay
                if showInfoPopup {
                    MapInfoPopupView(onDismiss: {
                        showInfoPopup = false
                        hasSeenMapInfoPopup = true
                    })
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .animation(.spring(), value: selectedHike)
            .animation(.easeInOut, value: showInfoPopup)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showFilterSheet) {
                MapFilterSheetView(
                    selectedTypeFilters: $selectedTypeFilters,
                    selectedTimePeriod: $selectedTimePeriod
                )
                .presentationDetents([.medium, .large])
            }
            .navigationDestination(item: $navigateToHike) { hike in
                if hike.status == "inProgress" {
                    ActiveHikeView(hike: hike)
                } else {
                    CompletedHikeDetailView(hike: hike)
                }
            }
            .onAppear {
                // Show info popup on first visit
                if !hasSeenMapInfoPopup {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showInfoPopup = true
                    }
                }
            }
        }
    }

    // MARK: - Map

    private var map: some View {
        Map(position: $cameraPosition) {
            ForEach(filteredHikesWithLocation) { hike in
                Annotation(
                    hike.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: hike.startLatitude ?? 0,
                        longitude: hike.startLongitude ?? 0
                    )
                ) {
                    MapMarker(
                        hike: hike,
                        iconName: iconForHikeType(hike.type),
                        isSelected: selectedHike?.id == hike.id,
                        onTap: {
                            selectAndZoomToHike(hike)
                        }
                    )
                }
            }
        }
        .mapStyle(currentMapStyle)
        .mapControls {
            MapCompass()
            // Hide MapScaleView to avoid overlap with buttons
        }
        .environment(\.colorScheme, .light)
        .onTapGesture {
            withAnimation(.spring()) {
                selectedHike = nil
            }
        }
    }

    // MARK: - Filter FAB

    private var filterFAB: some View {
        Button(action: {
            showFilterSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(HDColors.forestGreen)
                    .frame(width: HDSpacing.fabSize, height: HDSpacing.fabSize)
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                Image(systemName: "line.3.horizontal.decrease")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.white)

                // Badge with count when filters active
                if hasActiveFilters {
                    Text("\(filteredHikesWithLocation.count)")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(HDColors.amber)
                        .clipShape(Circle())
                        .offset(x: 20, y: -20)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hike Info Card

    private var hikeInfoCard: some View {
        HikeInfoCard(
            hike: selectedHike!,
            iconName: iconForHikeType(selectedHike!.type),
            onClose: {
                withAnimation(.spring()) {
                    selectedHike = nil
                }
            },
            onViewDetails: {
                navigateToHike = selectedHike
            }
        )
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.bottom, HDSpacing.md)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Helper Methods

    private var hikesWithLocation: [Hike] {
        hikes.filter { hike in
            hike.startLatitude != nil && hike.startLongitude != nil
        }
    }

    private var filteredHikesWithLocation: [Hike] {
        hikesWithLocation.filter { hike in
            // Type filter
            let passesTypeFilter = selectedTypeFilters.isEmpty || selectedTypeFilters.contains(hike.type)

            // Period filter
            let passesPeriodFilter = selectedTimePeriod.matches(date: hike.startTime)

            return passesTypeFilter && passesPeriodFilter
        }
    }

    private var hasActiveFilters: Bool {
        !selectedTypeFilters.isEmpty || selectedTimePeriod != .all
    }

    private func iconForHikeType(_ typeName: String) -> String {
        hikeTypes.first(where: { $0.name == typeName })?.iconName ?? "figure.hiking"
    }

    private func selectAndZoomToHike(_ hike: Hike) {
        withAnimation(.spring()) {
            selectedHike = hike

            // Zoom to street level
            if let lat = hike.startLatitude, let lon = hike.startLongitude {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                )
            }
        }
    }
}

// MARK: - Map Marker

struct MapMarker: View {
    let hike: Hike
    let iconName: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(markerColor)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                    .shadow(color: .black.opacity(0.3), radius: 4)

                Image(systemName: iconName)
                    .font(.system(size: isSelected ? 24 : 20))
                    .foregroundColor(.white)
            }
        }
        .animation(.spring(), value: isSelected)
    }

    private var markerColor: Color {
        if hike.status == "inProgress" {
            return HDColors.amber
        } else {
            return HDColors.forestGreen
        }
    }
}

// MARK: - Hike Info Card

struct HikeInfoCard: View {
    let hike: Hike
    let iconName: String
    let onClose: () -> Void
    let onViewDetails: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: HDSpacing.sm) {
                // Header with name, type icon, and close button
                HStack(alignment: .top) {
                    // Type icon
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(hike.status == "inProgress" ? HDColors.amber : HDColors.forestGreen)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(hike.name)
                            .font(.headline)
                            .foregroundColor(HDColors.forestGreen)

                        Text(hike.type)
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)
                    }

                    Spacer()

                    CircularButton(icon: "xmark", action: onClose, size: 32, style: .secondary)
                }

                Divider()
                    .background(HDColors.dividerColor)

                // Info items
                HStack(spacing: HDSpacing.md) {
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

                // Active hike indicator
                if hike.status == "inProgress" {
                    HStack(spacing: HDSpacing.xs) {
                        Circle()
                            .fill(HDColors.amber)
                            .frame(width: 8, height: 8)

                        Text("Actieve wandeling")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(HDColors.amber)
                    }
                    .padding(.vertical, HDSpacing.xs)
                }

                // View details button
                PrimaryButton(
                    title: hike.status == "inProgress" ? "Ga naar Wandeling" : "Bekijk Details",
                    action: onViewDetails,
                    icon: hike.status == "inProgress" ? "arrow.right" : "eye"
                )
            }
        }
    }
}

// MARK: - Info Item

struct InfoItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            Text(text)
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)
                .lineLimit(1)
        }
    }
}

// MARK: - Previews

#Preview {
    MapView()
        .modelContainer(for: [Hike.self, HikeType.self], inMemory: true)
}

#Preview("With Hikes") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Hike.self, HikeType.self, configurations: config)

    // Add hike types
    let types = [
        HikeType(name: "Dagwandeling", iconName: "sun.max", sortOrder: 0),
        HikeType(name: "Meerdaagse wandeling", iconName: "calendar", sortOrder: 1),
        HikeType(name: "Stadswandeling", iconName: "building.2", sortOrder: 2),
        HikeType(name: "Boswandeling", iconName: "tree", sortOrder: 3),
        HikeType(name: "Bergwandeling", iconName: "mountain.2", sortOrder: 4),
        HikeType(name: "Strandwandeling", iconName: "beach.umbrella", sortOrder: 5),
        HikeType(name: "LAW-route", iconName: "signpost.right", sortOrder: 6)
    ]
    types.forEach { container.mainContext.insert($0) }

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
