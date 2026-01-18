import SwiftUI
import SwiftData

struct HikesOverviewView: View {
    @Query(sort: \Hike.startTime, order: .reverse) private var allHikes: [Hike]
    @Environment(AppState.self) private var appState
    @State private var viewModel = HikesOverviewViewModel()
    @State private var showNewHike = false
    @State private var showSettings = false
    @State private var showMap = false
    @State private var showFilterSheet = false
    @State private var showActiveHikeAlert = false

    var displayedHikes: [Hike] {
        viewModel.filteredAndSortedHikes(from: allHikes)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    if displayedHikes.isEmpty {
                        if allHikes.isEmpty {
                            emptyState
                        } else {
                            emptySearchState
                        }
                    } else {
                        hikesList
                    }
                }
            }
            .navigationTitle("Mijn Wandelingen")
            .searchable(text: $viewModel.searchText, prompt: "Zoek wandelingen")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sorteren", selection: $viewModel.sortOption) {
                            ForEach(HikesOverviewViewModel.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }

                        Button {
                            showFilterSheet = true
                        } label: {
                            Label("Filter op type", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showMap = true
                        } label: {
                            Image(systemName: "map")
                        }

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    PrimaryButton(
                        title: "Nieuwe Wandeling",
                        action: {
                            if appState.activeHikeID != nil {
                                showActiveHikeAlert = true
                            } else {
                                showNewHike = true
                            }
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showNewHike) {
                NewHikeView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showMap) {
                MapView()
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheet
            }
            .alert("Actieve wandeling", isPresented: $showActiveHikeAlert) {
                Button("Annuleren", role: .cancel) {}

                if let activeHike = currentActiveHike {
                    Button("Ga naar actieve wandeling") {
                        // Navigatie gebeurt via de NavigationLink in de lijst
                    }
                }
            } message: {
                Text("Je hebt al een actieve wandeling. Voltooi deze eerst voordat je een nieuwe start.")
            }
            .onAppear {
                validateActiveHike()
            }
        }
    }

    private func validateActiveHike() {
        // Check if activeHikeID still exists and is in progress
        guard let activeID = appState.activeHikeID else { return }

        let hikeExists = allHikes.contains { hike in
            hike.id == activeID && hike.status == "inProgress"
        }

        // Reset if hike doesn't exist or is no longer in progress
        if !hikeExists {
            appState.activeHikeID = nil
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "figure.hiking",
            title: "Nog geen wandelingen",
            message: "Start je eerste wandeling om je wandeldagboek te beginnen",
            actionTitle: "Start Wandeling",
            action: {
                showNewHike = true
            }
        )
    }

    private var emptySearchState: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Geen resultaten",
            message: "Probeer een andere zoekopdracht of pas je filters aan"
        )
    }

    private var hikesList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(displayedHikes) { hike in
                    if hike.id == appState.activeHikeID {
                        NavigationLink(destination: ActiveHikeView(hike: hike)) {
                            HikeCardView(
                                hike: hike,
                                isActive: true
                            )
                        }
                        .buttonStyle(.plain)
                    } else if hike.status == "completed" {
                        NavigationLink(destination: CompletedHikeDetailView(hike: hike)) {
                            HikeCardView(
                                hike: hike,
                                isActive: false
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        HikeCardView(
                            hike: hike,
                            isActive: false
                        )
                    }
                }
            }
            .padding()
        }
    }

    private var currentActiveHike: Hike? {
        guard let activeID = appState.activeHikeID else { return nil }
        return allHikes.first { $0.id == activeID && $0.status == "inProgress" }
    }

    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Type wandeling") {
                    let availableTypes = viewModel.availableTypes(from: allHikes)

                    if availableTypes.isEmpty {
                        Text("Geen types beschikbaar")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(availableTypes, id: \.self) { type in
                            Toggle(type, isOn: Binding(
                                get: { viewModel.selectedTypes.contains(type) },
                                set: { isSelected in
                                    if isSelected {
                                        viewModel.selectedTypes.insert(type)
                                    } else {
                                        viewModel.selectedTypes.remove(type)
                                    }
                                }
                            ))
                        }
                    }
                }

                Section {
                    Button("Reset filters") {
                        viewModel.selectedTypes.removeAll()
                    }
                    .disabled(viewModel.selectedTypes.isEmpty)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Klaar") {
                        showFilterSheet = false
                    }
                }
            }
        }
    }
}

struct HikeCardView: View {
    let hike: Hike
    let isActive: Bool

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Status badge
                HStack {
                    Text(hike.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if isActive {
                        Text("Actief")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }

                // Type en datum
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.secondary)
                        Text(hike.type)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(formattedDate(hike.startTime))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if !hike.companions.isEmpty {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.secondary)
                            Text(hike.companions)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Locatie info
                if let location = hike.startLocationName {
                    HStack {
                        Image(systemName: "mappin.circle")
                            .foregroundColor(.secondary)
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let endLocation = hike.endLocationName, hike.status == "completed" {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(endLocation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Stats voor completed hikes
                if hike.status == "completed" {
                    Divider()

                    HStack(spacing: 20) {
                        if let distance = hike.distance {
                            StatView(
                                icon: "figure.hiking",
                                value: String(format: "%.1f km", distance)
                            )
                        }

                        if let rating = hike.rating {
                            StatView(
                                icon: "star.fill",
                                value: "\(rating)/10"
                            )
                        }
                    }
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "nl_NL")
        return formatter.string(from: date)
    }
}

struct StatView: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    HikesOverviewView()
        .environment(AppState())
}

#Preview("Empty State") {
    NavigationStack {
        EmptyStateView(
            icon: "figure.hiking",
            title: "Nog geen wandelingen",
            message: "Start je eerste wandeling om je wandeldagboek te beginnen"
        )
    }
}
