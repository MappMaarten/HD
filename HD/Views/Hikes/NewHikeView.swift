import SwiftUI
import SwiftData

struct NewHikeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @Query(sort: \HikeType.sortOrder) private var hikeTypes: [HikeType]
    @Query(sort: \LAWRoute.sortOrder) private var lawRoutes: [LAWRoute]

    @State private var viewModel = NewHikeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: HDSpacing.lg) {
                            // Header
                            journalHeader

                            // 1. Type selectie
                            typeSection

                            // 2. LAW velden (animated)
                            if viewModel.isLAWRoute {
                                lawSection
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            DashedDivider()

                            // 3. Naam & Gezelschap
                            detailsSection

                            DashedDivider()

                            // 4. Startlocatie
                            locationSection

                            DashedDivider()

                            // 5. Stemming
                            moodSection
                        }
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.md)
                        .padding(.bottom, 100)
                    }

                    // Sticky bottom button
                    stickyButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                    .foregroundColor(HDColors.forestGreen)
                }
            }
        }
    }

    // MARK: - Journal Header

    private var journalHeader: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Nieuwe wandeling")
                .font(.custom("Georgia-Bold", size: 28))
                .foregroundColor(HDColors.forestGreen)

            Text(Date().formatted(.dateTime.day().month(.wide).year()))
                .font(.custom("Georgia-Italic", size: 15))
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, HDSpacing.md)
    }

    // MARK: - Type Section

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            if hikeTypes.isEmpty {
                Text("Voeg wandeltypes toe in Instellingen")
                    .foregroundColor(HDColors.mutedGreen)
                    .font(.subheadline)
            } else {
                HikeTypeSelector(
                    types: hikeTypes,
                    selectedType: $viewModel.selectedHikeType
                )
                .onChange(of: viewModel.selectedHikeType) { _, _ in
                    withAnimation(.spring(response: 0.4)) {
                        viewModel.updateNameFromType()
                    }
                }
            }

            if let error = viewModel.typeError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - LAW Section

    private var lawSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.md) {
            // Route picker
            VStack(alignment: .leading, spacing: HDSpacing.xs) {
                Text("Route")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(HDColors.forestGreen)

                if lawRoutes.isEmpty {
                    Text("Voeg LAW routes toe in Instellingen")
                        .foregroundColor(HDColors.mutedGreen)
                        .font(.caption)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HDSpacing.xs) {
                            ForEach(lawRoutes) { route in
                                lawRouteChip(route)
                            }
                        }
                    }
                    .onChange(of: viewModel.selectedLAWRoute) { _, _ in
                        viewModel.updateNameFromType()
                    }
                }
            }

            // Etappe stepper (only if route selected)
            if let selectedRoute = viewModel.selectedLAWRoute {
                VStack(alignment: .leading, spacing: HDSpacing.xs) {
                    Text("Etappe")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(HDColors.forestGreen)

                    HStack {
                        Button {
                            if viewModel.lawStageNumber > 1 {
                                viewModel.lawStageNumber -= 1
                                viewModel.updateNameFromType()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.lawStageNumber > 1 ? HDColors.forestGreen : HDColors.mutedGreen)
                        }
                        .disabled(viewModel.lawStageNumber <= 1)

                        Text("\(viewModel.lawStageNumber)")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(HDColors.forestGreen)
                            .frame(minWidth: 40)

                        Button {
                            if viewModel.lawStageNumber < selectedRoute.stagesCount {
                                viewModel.lawStageNumber += 1
                                viewModel.updateNameFromType()
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.lawStageNumber < selectedRoute.stagesCount ? HDColors.forestGreen : HDColors.mutedGreen)
                        }
                        .disabled(viewModel.lawStageNumber >= selectedRoute.stagesCount)

                        Spacer()

                        Text("van \(selectedRoute.stagesCount)")
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)
                    }
                    .padding(HDSpacing.sm)
                    .background(HDColors.sageGreen)
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
            }
        }
    }

    private func lawRouteChip(_ route: LAWRoute) -> some View {
        let isSelected = viewModel.selectedLAWRoute?.id == route.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedLAWRoute = route
            }
        } label: {
            Text(route.name)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, HDSpacing.sm)
                .padding(.vertical, HDSpacing.xs)
                .background(isSelected ? HDColors.forestGreen : HDColors.sageGreen)
                .foregroundColor(isSelected ? .white : HDColors.forestGreen)
                .cornerRadius(HDSpacing.cornerRadiusSmall)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(spacing: HDSpacing.sm) {
            VStack(alignment: .leading, spacing: HDSpacing.xs) {
                HDTextField(
                    "Naam van je wandeling",
                    text: $viewModel.name
                )

                if let error = viewModel.nameError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            HDTextField(
                "Gezelschap (optioneel)",
                text: $viewModel.companions,
                icon: "person.2"
            )
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            HDTextField(
                "Startlocatie",
                text: $viewModel.startLocationName,
                icon: "mappin"
            ) {
                GPSButton(
                    isLoading: viewModel.locationService.isLoadingLocation,
                    hasLocation: viewModel.startLatitude != nil,
                    action: { viewModel.fetchCurrentLocation() }
                )
            }

            if let error = viewModel.locationService.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            if viewModel.startLatitude != nil, viewModel.startLongitude != nil,
               viewModel.locationService.locationError == nil {
                HStack(spacing: HDSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(HDColors.forestGreen)
                    Text("GPS coördinaten opgeslagen")
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
        }
    }

    // MARK: - Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            CompactMoodSlider(value: $viewModel.startMood)
        }
    }

    // MARK: - Sticky Button

    private var stickyButton: some View {
        VStack {
            PrimaryButton(
                title: "Start Wandeling",
                action: { startHike() },
                isEnabled: viewModel.isValid
            )
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.vertical, HDSpacing.md)
        }
        .background(
            HDColors.cream
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
        )
    }

    // MARK: - Actions

    private func startHike() {
        guard appState.activeHikeID == nil else {
            dismiss()
            return
        }

        guard viewModel.validate() else { return }
        guard let hikeType = viewModel.selectedHikeType else { return }

        let newHike = Hike(
            status: "inProgress",
            name: viewModel.name,
            type: hikeType.name,
            companions: viewModel.companions,
            startLatitude: viewModel.startLatitude,
            startLongitude: viewModel.startLongitude,
            startLocationName: viewModel.startLocationName.isEmpty ? nil : viewModel.startLocationName,
            startTime: Date(),
            startMood: Int(viewModel.startMood),
            lawRouteName: viewModel.selectedLAWRoute?.name,
            lawStageNumber: viewModel.isLAWRoute ? viewModel.lawStageNumber : nil
        )

        modelContext.insert(newHike)
        appState.activeHikeID = newHike.id

        dismiss()
    }
}

#Preview {
    NewHikeView()
        .modelContainer(for: [Hike.self, HikeType.self, LAWRoute.self], inMemory: true)
        .environment(AppState())
}
