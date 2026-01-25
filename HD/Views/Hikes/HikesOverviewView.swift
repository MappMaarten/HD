//
//  HikesOverviewView.swift
//  HD
//
//  Redesigned hikes overview with dagboek (journal) styling and filter tabs
//

import SwiftUI
import SwiftData

struct HikesOverviewView: View {
    @Query(sort: \Hike.startTime, order: .reverse) private var allHikes: [Hike]
    @Environment(AppState.self) private var appState
    @State private var showNewHike = false
    @State private var showSettings = false
    @State private var showMap = false
    @State private var showFilterPanel = false
    @State private var showActiveHikeAlert = false
    @State private var searchText = ""
    @State private var selectedTypes: Set<String> = []
    @State private var sortOption: SortOption = .dateDescending

    enum SortOption: String, CaseIterable {
        case dateDescending = "Nieuwste eerst"
        case dateAscending = "Oudste eerst"
        case nameAscending = "Naam A-Z"
        case nameDescending = "Naam Z-A"
    }

    // MARK: - Filtered Hikes

    private var filteredHikes: [Hike] {
        var hikes = allHikes

        // Filter by search text
        if !searchText.isEmpty {
            hikes = hikes.filter { hike in
                hike.name.localizedCaseInsensitiveContains(searchText) ||
                hike.type.localizedCaseInsensitiveContains(searchText) ||
                (hike.startLocationName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Filter by selected types
        if !selectedTypes.isEmpty {
            hikes = hikes.filter { selectedTypes.contains($0.type) }
        }

        // Sort
        switch sortOption {
        case .dateDescending:
            hikes.sort { $0.startTime > $1.startTime }
        case .dateAscending:
            hikes.sort { $0.startTime < $1.startTime }
        case .nameAscending:
            hikes.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDescending:
            hikes.sort { $0.name.localizedCompare($1.name) == .orderedDescending }
        }

        return hikes
    }

    private var displayedHikesWithoutActive: [Hike] {
        // Exclude active hike from main list (shown separately in banner)
        filteredHikes.filter { $0.id != appState.activeHikeID }
    }

    private var currentActiveHike: Hike? {
        guard let activeID = appState.activeHikeID else { return nil }
        return allHikes.first { $0.id == activeID && $0.status == "inProgress" }
    }

    private var availableTypes: [String] {
        Array(Set(allHikes.map { $0.type })).sorted()
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    customHeader
                    titleSection

                    if showFilterPanel {
                        filterPanel
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    contentArea
                }

                // FAB overlay
                fabOverlay
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewHike) {
                NewHikeView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showMap) {
                MapView()
            }
            .alert("Actieve wandeling", isPresented: $showActiveHikeAlert) {
                Button("Annuleren", role: .cancel) {}
                if currentActiveHike != nil {
                    Button("Ga naar actieve wandeling") {
                        // Navigation happens via banner
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

    // MARK: - Custom Header

    private var customHeader: some View {
        HStack {
            ListMapToggle(showMap: $showMap)
            Spacer()
            CircularButton(icon: "gear") {
                showSettings = true
            }
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Jouw wandelingen \u{00B7} \(allHikes.count)")
                .hdHandwritten(size: 24)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showFilterPanel.toggle()
                }
            } label: {
                Image(systemName: showFilterPanel ? "xmark" : "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(HDColors.forestGreen)
            }
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.vertical, HDSpacing.md)
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if allHikes.isEmpty {
            emptyState
        } else if filteredHikes.isEmpty {
            emptySearchState
        } else {
            hikesList
        }
    }

    // MARK: - Hikes List

    private var hikesList: some View {
        ScrollView {
            VStack(spacing: HDSpacing.md) {
                // Active hike banner
                if let activeHike = currentActiveHike {
                    NavigationLink(destination: ActiveHikeView(hike: activeHike)) {
                        ActiveHikeBanner(hike: activeHike)
                    }
                    .buttonStyle(.plain)
                }

                // Regular hike cards
                ForEach(displayedHikesWithoutActive) { hike in
                    if hike.status == "completed" {
                        NavigationLink(destination: CompletedHikeDetailView(hike: hike)) {
                            HikeCardView(hike: hike)
                        }
                        .buttonStyle(.plain)
                    } else {
                        NavigationLink(destination: ActiveHikeView(hike: hike)) {
                            HikeCardView(hike: hike)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.bottom, HDSpacing.fabSize + HDSpacing.fabMargin * 2)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Empty States

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
            message: "Probeer een andere zoekopdracht of pas je filters aan",
            useCircularIcon: false
        )
    }

    // MARK: - FAB Overlay

    private var fabOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(icon: "plus") {
                    if appState.activeHikeID != nil {
                        showActiveHikeAlert = true
                    } else {
                        showNewHike = true
                    }
                }
            }
        }
        .padding(.trailing, HDSpacing.fabMargin)
        .padding(.bottom, HDSpacing.fabMargin)
    }

    // MARK: - Inline Filter Panel

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            // Row 1: Search bar + Sort picker
            HStack(spacing: HDSpacing.sm) {
                // Compact search bar
                HStack(spacing: HDSpacing.xs) {
                    Image(systemName: "magnifyingglass")
                        .font(.subheadline)
                        .foregroundColor(HDColors.forestGreen)
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Zoek...")
                                .font(.subheadline)
                                .foregroundColor(HDColors.mutedGreen)
                        }
                        TextField("", text: $searchText)
                            .font(.subheadline)
                            .foregroundColor(HDColors.forestGreen)
                    }
                }
                .padding(.horizontal, HDSpacing.sm)
                .padding(.vertical, HDSpacing.xs)
                .background(HDColors.sageGreen)
                .cornerRadius(HDSpacing.cornerRadiusSmall)

                // Compact sort picker
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Sorteren")
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(HDColors.forestGreen)
                    .padding(.horizontal, HDSpacing.sm)
                    .padding(.vertical, HDSpacing.xs)
                    .background(HDColors.sageGreen)
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
            }

            // Row 2: Type chips + Reset button
            HStack(spacing: HDSpacing.sm) {
                if !availableTypes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HDSpacing.xs) {
                            ForEach(availableTypes, id: \.self) { type in
                                typeFilterChip(type)
                            }
                        }
                    }
                }

                Spacer()

                // Reset button (always visible, but dimmed when no filters active)
                let hasFilters = !selectedTypes.isEmpty || sortOption != .dateDescending || !searchText.isEmpty
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTypes.removeAll()
                        sortOption = .dateDescending
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline)
                        .foregroundColor(hasFilters ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                }
                .disabled(!hasFilters)
            }
        }
        .padding(HDSpacing.sm)
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.bottom, HDSpacing.xs)
    }

    private func typeFilterChip(_ type: String) -> some View {
        let isSelected = selectedTypes.contains(type)

        return Button {
            withAnimation(.spring(response: 0.3)) {
                if isSelected {
                    selectedTypes.remove(type)
                } else {
                    selectedTypes.insert(type)
                }
            }
        } label: {
            Text(type)
                .font(.caption.weight(.medium))
                .padding(.horizontal, HDSpacing.sm)
                .padding(.vertical, HDSpacing.xs)
                .background(isSelected ? HDColors.forestGreen : HDColors.sageGreen)
                .foregroundColor(isSelected ? .white : HDColors.forestGreen)
                .cornerRadius(HDSpacing.cornerRadiusSmall)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func validateActiveHike() {
        guard let activeID = appState.activeHikeID else { return }

        let hikeExists = allHikes.contains { hike in
            hike.id == activeID && hike.status == "inProgress"
        }

        if !hikeExists {
            appState.activeHikeID = nil
        }
    }
}

// MARK: - Previews

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
    .background(HDColors.cream)
}
