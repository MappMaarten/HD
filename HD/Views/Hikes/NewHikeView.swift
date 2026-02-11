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
                        VStack(alignment: .leading, spacing: HDSpacing.md) {
                            // Header
                            journalHeader

                            // 1. Type selectie (prominent, standalone)
                            typeSection

                            // 2. LAW velden (animated)
                            if viewModel.isLAWRoute {
                                FormSection(title: "LAW Route", icon: "map") {
                                    lawContent
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // 3. Naam & Gezelschap (grouped in card)
                            FormSection(title: "Details", icon: "pencil") {
                                detailsContent
                            }

                            // 4. Startlocatie (grouped in card)
                            FormSection(title: "Locatie", icon: "mappin") {
                                locationContent
                            }

                            // 5. Stemming (grouped in card)
                            FormSection(title: "Hoe voel je je?", icon: "heart") {
                                NatureMoodSlider(value: $viewModel.startMood)
                            }
                        }
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.md)
                        .padding(.bottom, HDSpacing.lg)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .keyboardAdaptive(tabBarHeight: 0)

                    // Sticky bottom button
                    stickyButton
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(HDColors.forestGreen)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        hideKeyboard()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(HDColors.forestGreen)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - Journal Header

    private var journalHeader: some View {
        HStack(alignment: .center, spacing: HDSpacing.sm) {
            Text("Nieuwe wandeling")
                .font(.custom("Georgia-Bold", size: 24))
                .foregroundColor(HDColors.forestGreen)

            Spacer()

            Text(Date().formatted(.dateTime.day().month(.abbreviated)))
                .font(.custom("Georgia-Italic", size: 13))
                .foregroundColor(HDColors.mutedGreen.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
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

            if viewModel.hasAttemptedStart, let error = viewModel.typeError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - LAW Content

    private var lawContent: some View {
        VStack(alignment: .leading, spacing: HDSpacing.md) {
            // Route picker
            VStack(alignment: .leading, spacing: HDSpacing.xs) {
                Text("Route")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(HDColors.forestGreen)

                if lawRoutes.isEmpty {
                    Text("Voeg eerst LAW routes toe in Instellingen")
                        .foregroundColor(HDColors.mutedGreen)
                        .font(.caption)
                } else {
                    LAWRouteSelector(
                        routes: lawRoutes,
                        selectedRoute: $viewModel.selectedLAWRoute
                    )
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

                    HStack(spacing: HDSpacing.md) {
                        // Pill-shaped stepper
                        HStack(spacing: 0) {
                            Button {
                                if viewModel.lawStageNumber > 1 {
                                    viewModel.lawStageNumber -= 1
                                    viewModel.updateNameFromType()
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(viewModel.lawStageNumber > 1 ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                                    .frame(width: 44, height: 40)
                            }
                            .disabled(viewModel.lawStageNumber <= 1)

                            Text("\(viewModel.lawStageNumber)")
                                .font(.title3.weight(.bold))
                                .foregroundColor(HDColors.forestGreen)
                                .frame(minWidth: 32)

                            Button {
                                if viewModel.lawStageNumber < selectedRoute.stagesCount {
                                    viewModel.lawStageNumber += 1
                                    viewModel.updateNameFromType()
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(viewModel.lawStageNumber < selectedRoute.stagesCount ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                                    .frame(width: 44, height: 40)
                            }
                            .disabled(viewModel.lawStageNumber >= selectedRoute.stagesCount)
                        }
                        .background(Color.white.opacity(0.5))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(HDColors.dividerColor.opacity(0.3), lineWidth: 1)
                        )

                        Text("van \(selectedRoute.stagesCount)")
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)

                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Details Content

    private var detailsContent: some View {
        VStack(spacing: HDSpacing.md) {
            // Name field - conditional rendering based on LAW route
            VStack(alignment: .leading, spacing: HDSpacing.xs) {
                if viewModel.isLAWRoute {
                    // LAW route: Show name as read-only text
                    VStack(alignment: .leading, spacing: HDSpacing.xs) {
                        Text("Naam van je wandeling")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(HDColors.forestGreen)

                        HStack(spacing: HDSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(HDColors.mutedGreen)
                                .font(.subheadline)
                                .frame(width: 20)

                            Text(viewModel.name)
                                .foregroundColor(HDColors.forestGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, HDSpacing.md)
                        .padding(.vertical, HDSpacing.sm + 2)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(HDSpacing.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                .stroke(HDColors.dividerColor.opacity(0.2), lineWidth: 1)
                        )

                        Text("Naam wordt automatisch overgenomen van de geselecteerde LAW-route")
                            .font(.caption)
                            .foregroundColor(HDColors.mutedGreen)
                    }
                } else {
                    // Regular hike: Show editable text field
                    HDTextField(
                        "Naam van je wandeling",
                        text: $viewModel.name
                    )

                    if viewModel.hasAttemptedStart, let error = viewModel.nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            // Companions field (always visible and editable)
            HDTextField(
                "Gezelschap",
                text: $viewModel.companions
            )
        }
    }

    // MARK: - Location Content

    private var locationContent: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            HDTextField(
                "Startlocatie",
                text: $viewModel.startLocationName,
                icon: "location"
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
            } else if viewModel.startLatitude != nil, viewModel.startLongitude != nil {
                Text("GPS coördinaten opgeslagen - wordt toegevoegd aan je wandelingenkaart")
                    .font(.caption)
                    .foregroundColor(HDColors.forestGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(HDSpacing.sm)
                    .background(HDColors.forestGreen.opacity(0.05))
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                    Text("Tik op \(Image(systemName: "location.fill")) om de wandeling aan je wandelkaart toe te voegen")
                        .font(.caption)
                }
                .foregroundColor(HDColors.mutedGreen.opacity(0.8))
            }
        }
    }

    // MARK: - Sticky Button

    private var stickyButton: some View {
        VStack {
            PrimaryButton(
                title: "Start Wandeling",
                action: { startHike() },
                icon: "figure.walk",
                isEnabled: viewModel.canStart
            )
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.vertical, HDSpacing.md)
        }
        .background(
            HDColors.cream
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -6)
        )
    }

    // MARK: - Actions

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

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

        // Schedule hike reminders if enabled
        if UserDefaults.standard.bool(forKey: "notificationsEnabled"),
           UserDefaults.standard.bool(forKey: "activeHikeReminderEnabled") {
            let interval = UserDefaults.standard.integer(forKey: "activeHikeReminderInterval")
            NotificationService.shared.scheduleHikeReminders(intervalMinutes: interval == 0 ? 30 : interval)
        }
        NotificationService.shared.onHikeStarted()

        dismiss()
    }
}

#Preview {
    NewHikeView()
        .modelContainer(for: [Hike.self, HikeType.self, LAWRoute.self], inMemory: true)
        .environment(AppState())
}
