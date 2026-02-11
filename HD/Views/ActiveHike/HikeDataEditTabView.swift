import SwiftUI
import SwiftData

struct HikeDataEditTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel

    @Query(sort: \HikeType.sortOrder) private var hikeTypes: [HikeType]
    @Query(sort: \LAWRoute.sortOrder) private var lawRoutes: [LAWRoute]

    @State private var selectedHikeType: HikeType?
    @State private var selectedLAWRoute: LAWRoute?
    @State private var lawStageNumber: Int = 1

    @State private var name: String = ""
    @State private var companions: String = ""
    @State private var startLocationName: String = ""
    @State private var startTime: Date = Date()
    @State private var startMood: Double = 5.0

    @State private var endTime: Date = Date()
    @State private var endLocationName: String = ""
    @State private var distance: String = ""
    @State private var rating: Double = 5.0
    @State private var endMood: Double = 5.0
    @State private var reflection: String = ""

    let startLocationService = LocationService()
    let endLocationService = LocationService()

    private let reflectionPlaceholder = "Wat blijft je bij van deze wandeling? Welk moment, gevoel of beeld neem je mee?"

    private var isLAWRoute: Bool {
        selectedHikeType?.name.lowercased().contains("law") ?? false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HDSpacing.md) {
                        // Header
                        Text("Pas de gegevens van je wandeling aan.")
                            .font(.custom("Georgia-Italic", size: 15))
                            .foregroundColor(HDColors.mutedGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, HDSpacing.md)

                        // MARK: - Tijden
                        sectionHeader("Tijden", icon: "clock")

                        FormSection(title: "Starttijd", icon: "clock") {
                            DatePicker(
                                "Starttijd",
                                selection: $startTime,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .tint(HDColors.forestGreen)
                            .onChange(of: startTime) { _, newValue in
                                viewModel.hike.startTime = newValue
                                viewModel.hike.updatedAt = Date()
                            }
                        }

                        FormSection(title: "Eindtijd", icon: "clock") {
                            DatePicker(
                                "Eindtijd",
                                selection: $endTime,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .tint(HDColors.forestGreen)
                            .onChange(of: endTime) { _, newValue in
                                viewModel.hike.endTime = newValue
                                viewModel.hike.updatedAt = Date()
                            }
                        }

                        // MARK: - Locaties
                        sectionHeader("Locaties", icon: "mappin")
                            .padding(.top, HDSpacing.md)

                        FormSection(title: "Startlocatie", icon: "mappin") {
                            startLocationContent
                        }

                        FormSection(title: "Eindlocatie", icon: "mappin.and.ellipse") {
                            endLocationContent
                        }

                        // MARK: - Wandelgegevens
                        sectionHeader("Wandelgegevens", icon: "figure.walk")
                            .padding(.top, HDSpacing.md)

                        FormSection(title: "Type", icon: "figure.walk") {
                            HikeTypeSelector(
                                types: hikeTypes,
                                selectedType: $selectedHikeType
                            )
                            .onChange(of: selectedHikeType) { _, newType in
                                if let newType {
                                    viewModel.hike.type = newType.name
                                }
                                // If switching away from LAW, clear LAW fields
                                if !isLAWRoute {
                                    selectedLAWRoute = nil
                                    viewModel.hike.lawRouteName = nil
                                    viewModel.hike.lawStageNumber = nil
                                }
                                updateNameFromType()
                                viewModel.hike.updatedAt = Date()
                            }
                        }

                        if isLAWRoute {
                            FormSection(title: "LAW Route", icon: "map") {
                                VStack(alignment: .leading, spacing: HDSpacing.sm) {
                                    LAWRouteSelector(
                                        routes: lawRoutes,
                                        selectedRoute: $selectedLAWRoute
                                    )
                                    .onChange(of: selectedLAWRoute) { _, newRoute in
                                        if let newRoute {
                                            viewModel.hike.lawRouteName = newRoute.name
                                            lawStageNumber = 1
                                            viewModel.hike.lawStageNumber = 1
                                        } else {
                                            viewModel.hike.lawRouteName = nil
                                            viewModel.hike.lawStageNumber = nil
                                        }
                                        updateNameFromType()
                                        viewModel.hike.updatedAt = Date()
                                    }

                                    // Etappe stepper
                                    if let selectedRoute = selectedLAWRoute {
                                        etappeStepper(route: selectedRoute)
                                    }
                                }
                            }
                        }

                        FormSection(title: "Naam", icon: "pencil") {
                            if isLAWRoute {
                                readOnlyNameView
                            } else {
                                HDTextField(
                                    "Naam van je wandeling",
                                    text: $name
                                )
                                .onChange(of: name) { _, newValue in
                                    viewModel.hike.name = newValue
                                    viewModel.hike.updatedAt = Date()
                                }
                            }
                        }

                        FormSection(title: "Gezelschap", icon: "person.2") {
                            HDTextField(
                                "Gezelschap",
                                text: $companions
                            )
                            .onChange(of: companions) { _, newValue in
                                viewModel.hike.companions = newValue
                                viewModel.hike.updatedAt = Date()
                            }
                        }

                        FormSection(title: "Afstand", icon: "point.topleft.down.to.point.bottomright.curvepath") {
                            HDTextField(
                                "Bijv. 12.5",
                                text: $distance,
                                icon: "ruler",
                                keyboardType: .decimalPad
                            ) {
                                Text("km")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(HDColors.mutedGreen)
                            }
                            .onChange(of: distance) { _, newValue in
                                let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                                viewModel.hike.distance = Double(normalized)
                                viewModel.hike.updatedAt = Date()
                            }
                        }

                        // MARK: - Beleving
                        sectionHeader("Beleving", icon: "heart")
                            .padding(.top, HDSpacing.md)

                        FormSection(title: "Hoe voelde je je?", icon: "heart") {
                            NatureMoodSlider(value: $startMood)
                                .onChange(of: startMood) { _, newValue in
                                    viewModel.hike.startMood = Int(newValue)
                                    viewModel.hike.updatedAt = Date()
                                }
                        }

                        FormSection(title: "Hoe heb je de wandeling ervaren?", icon: "star") {
                            HikeRatingSlider(value: $rating)
                                .onChange(of: rating) { _, newValue in
                                    viewModel.hike.rating = Int(newValue)
                                    viewModel.hike.updatedAt = Date()
                                }
                        }

                        FormSection(title: "Hoe voel je je nu?", icon: "heart") {
                            VStack(spacing: HDSpacing.md) {
                                NatureMoodSlider(value: $endMood, context: .post)
                                    .onChange(of: endMood) { _, newValue in
                                        viewModel.hike.endMood = Int(newValue)
                                        viewModel.hike.updatedAt = Date()
                                    }
                                moodComparisonView
                            }
                        }

                        FormSection(title: "Reflectie", icon: "text.quote") {
                            reflectionContent
                        }
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.top, HDSpacing.md)
                    .padding(.bottom, HDSpacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .keyboardAdaptive()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        hideKeyboard()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(HDColors.forestGreen)
                }
            }
        }
        .onAppear {
            loadData()
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: HDSpacing.sm) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(HDColors.forestGreen)
            Text(title)
                .font(.headline)
                .foregroundColor(HDColors.forestGreen)
        }
        .padding(.top, HDSpacing.sm)
    }

    // MARK: - Read-Only Name (LAW)

    private var readOnlyNameView: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            HStack(spacing: HDSpacing.sm) {
                Image(systemName: "lock.fill")
                    .foregroundColor(HDColors.mutedGreen)
                    .font(.subheadline)
                    .frame(width: 20)

                Text(name)
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
    }

    // MARK: - Etappe Stepper

    private func etappeStepper(route: LAWRoute) -> some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Etappe")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            HStack(spacing: HDSpacing.md) {
                HStack(spacing: 0) {
                    Button {
                        if lawStageNumber > 1 {
                            lawStageNumber -= 1
                            viewModel.hike.lawStageNumber = lawStageNumber
                            viewModel.hike.updatedAt = Date()
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.body.weight(.semibold))
                            .foregroundColor(lawStageNumber > 1 ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                            .frame(width: 44, height: 40)
                    }
                    .disabled(lawStageNumber <= 1)

                    Text("\(lawStageNumber)")
                        .font(.title3.weight(.bold))
                        .foregroundColor(HDColors.forestGreen)
                        .frame(minWidth: 32)

                    Button {
                        if lawStageNumber < route.stagesCount {
                            lawStageNumber += 1
                            viewModel.hike.lawStageNumber = lawStageNumber
                            viewModel.hike.updatedAt = Date()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundColor(lawStageNumber < route.stagesCount ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                            .frame(width: 44, height: 40)
                    }
                    .disabled(lawStageNumber >= route.stagesCount)
                }
                .background(Color.white.opacity(0.5))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(HDColors.dividerColor.opacity(0.3), lineWidth: 1)
                )

                Text("van \(route.stagesCount)")
                    .font(.subheadline)
                    .foregroundColor(HDColors.mutedGreen)

                Spacer()
            }
        }
    }

    // MARK: - Start Location Content

    private var startLocationContent: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            HDTextField(
                "Startlocatie",
                text: $startLocationName,
                icon: "location"
            ) {
                GPSButton(
                    isLoading: startLocationService.isLoadingLocation,
                    hasLocation: startLocationService.fetchedLatitude != nil,
                    action: { fetchStartLocation() }
                )
            }
            .onChange(of: startLocationName) { _, newValue in
                viewModel.hike.startLocationName = newValue.isEmpty ? nil : newValue
                viewModel.hike.updatedAt = Date()
            }

            if let error = startLocationService.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else if startLocationService.fetchedLatitude != nil, startLocationService.fetchedLongitude != nil {
                Text("GPS coördinaten opgeslagen")
                    .font(.caption)
                    .foregroundColor(HDColors.forestGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(HDSpacing.sm)
                    .background(HDColors.forestGreen.opacity(0.05))
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
            } else if viewModel.hike.startLatitude != nil {
                Text("GPS coördinaten aanwezig")
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
                    Text("Tik op \(Image(systemName: "location.fill")) om je huidige locatie op te halen")
                        .font(.caption)
                }
                .foregroundColor(HDColors.mutedGreen.opacity(0.8))
            }
        }
    }

    // MARK: - End Location Content

    private var endLocationContent: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            HDTextField(
                "Eindlocatie",
                text: $endLocationName,
                icon: "location"
            ) {
                GPSButton(
                    isLoading: endLocationService.isLoadingLocation,
                    hasLocation: endLocationService.fetchedLatitude != nil,
                    action: { fetchEndLocation() }
                )
            }
            .onChange(of: endLocationName) { _, newValue in
                viewModel.hike.endLocationName = newValue.isEmpty ? nil : newValue
                viewModel.hike.updatedAt = Date()
            }

            if let error = endLocationService.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else if endLocationService.fetchedLatitude != nil, endLocationService.fetchedLongitude != nil {
                Text("GPS coördinaten opgeslagen")
                    .font(.caption)
                    .foregroundColor(HDColors.forestGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(HDSpacing.sm)
                    .background(HDColors.forestGreen.opacity(0.05))
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
            } else if viewModel.hike.endLatitude != nil {
                Text("GPS coördinaten aanwezig")
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
                    Text("Tik op \(Image(systemName: "location.fill")) om je huidige locatie op te halen")
                        .font(.caption)
                }
                .foregroundColor(HDColors.mutedGreen.opacity(0.8))
            }
        }
    }

    // MARK: - Mood Comparison View

    private var moodComparisonView: some View {
        HStack(spacing: HDSpacing.xs) {
            Text("Startstemming: \(viewModel.hike.startMood)")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            Spacer()

            let startMoodValue = viewModel.hike.startMood
            let currentEndMood = Int(endMood)
            let difference = currentEndMood - startMoodValue

            if difference > 0 {
                Label("+\(difference)", systemImage: "arrow.up.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(HDColors.forestGreen)
            } else if difference < 0 {
                Label("\(difference)", systemImage: "arrow.down.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(HDColors.amber)
            } else {
                Text("Gelijk gebleven")
                    .font(.caption)
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
        .padding(.top, HDSpacing.xs)
    }

    // MARK: - Reflection Content

    private var reflectionContent: some View {
        ZStack(alignment: .topLeading) {
            if reflection.isEmpty {
                Text(reflectionPlaceholder)
                    .font(.custom("Georgia-Italic", size: 15))
                    .foregroundColor(HDColors.mutedGreen.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $reflection)
                .font(.body)
                .foregroundColor(HDColors.forestGreen)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 120)
                .onChange(of: reflection) { _, newValue in
                    viewModel.hike.reflection = newValue
                    viewModel.hike.updatedAt = Date()
                }
        }
        .padding(HDSpacing.sm)
        .background(Color.white.opacity(0.5))
        .cornerRadius(HDSpacing.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                .stroke(HDColors.dividerColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func loadData() {
        // Start data
        name = viewModel.hike.name
        companions = viewModel.hike.companions
        startLocationName = viewModel.hike.startLocationName ?? ""
        startTime = viewModel.hike.startTime
        startMood = Double(viewModel.hike.startMood)

        // End data
        endTime = viewModel.hike.endTime ?? Date()
        endLocationName = viewModel.hike.endLocationName ?? ""
        if let dist = viewModel.hike.distance {
            distance = String(dist)
        }
        rating = Double(viewModel.hike.rating ?? 5)
        endMood = Double(viewModel.hike.endMood ?? viewModel.hike.startMood)
        reflection = viewModel.hike.reflection

        // Match HikeType by name
        selectedHikeType = hikeTypes.first { $0.name == viewModel.hike.type }

        // Match LAWRoute by name
        if let lawRouteName = viewModel.hike.lawRouteName {
            selectedLAWRoute = lawRoutes.first { $0.name == lawRouteName }
        }
        lawStageNumber = viewModel.hike.lawStageNumber ?? 1
    }

    private func updateNameFromType() {
        if isLAWRoute, let lawRoute = selectedLAWRoute {
            name = lawRoute.name
            viewModel.hike.name = lawRoute.name
        }
    }

    private func fetchStartLocation() {
        startLocationService.fetchCurrentLocation { result in
            switch result {
            case .success(let locationData):
                startLocationName = locationData.name
                viewModel.hike.startLatitude = startLocationService.fetchedLatitude
                viewModel.hike.startLongitude = startLocationService.fetchedLongitude
                viewModel.hike.startLocationName = locationData.name
                viewModel.hike.updatedAt = Date()
            case .failure:
                break
            }
        }
    }

    private func fetchEndLocation() {
        endLocationService.fetchCurrentLocation { result in
            switch result {
            case .success(let locationData):
                endLocationName = locationData.name
                viewModel.hike.endLatitude = endLocationService.fetchedLatitude
                viewModel.hike.endLongitude = endLocationService.fetchedLongitude
                viewModel.hike.endLocationName = locationData.name
                viewModel.hike.updatedAt = Date()
            case .failure:
                break
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

#Preview {
    HikeDataEditTabView(
        viewModel: ActiveHikeViewModel(
            hike: Hike(
                status: "completed",
                name: "Test Wandeling",
                type: "Dagwandeling",
                startMood: 6,
                endTime: Date(),
                distance: 12.5,
                rating: 7,
                endMood: 8,
                reflection: "Een mooie wandeling."
            )
        )
    )
}
