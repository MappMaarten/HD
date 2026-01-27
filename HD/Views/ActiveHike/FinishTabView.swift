import SwiftUI

struct FinishTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var distance: String = ""
    @State private var rating: Double = 5.0
    @State private var endMood: Double = 5.0
    @State private var reflection: String = ""
    @State private var endTime = Date()
    @State private var endLocationName: String = ""
    @State private var showCompletionOverlay = false

    let locationService = LocationService()

    private let reflectionPlaceholder = "Wat blijft je bij van deze wandeling? Welk moment, gevoel of beeld neem je mee?"

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

                            // 1. Eindtijd
                            FormSection(title: "Eindtijd", icon: "clock") {
                                endTimeContent
                            }

                            // 2. Eindlocatie
                            FormSection(title: "Eindlocatie", icon: "mappin.and.ellipse") {
                                locationContent
                            }

                            // 3. Afstand
                            FormSection(title: "Afstand", icon: "point.topleft.down.to.point.bottomright.curvepath") {
                                distanceContent
                            }

                            // 4. Wandelwaardering
                            FormSection(title: "Hoe heb je de wandeling ervaren?", icon: "star") {
                                HikeRatingSlider(value: $rating)
                            }

                            // 5. Eindstemming met vergelijking
                            FormSection(title: "Hoe voel je je nu?", icon: "heart") {
                                VStack(spacing: HDSpacing.md) {
                                    NatureMoodSlider(value: $endMood)
                                    moodComparisonView
                                }
                            }

                            // 6. Reflectie
                            FormSection(title: "Reflectie", icon: "text.quote") {
                                reflectionContent
                            }
                        }
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.top, HDSpacing.md)
                        .padding(.bottom, 120)
                    }

                    // Sticky bottom button
                    stickyButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .overlay {
                if showCompletionOverlay {
                    HikeCompletionOverlay {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Initialize endMood with startMood value
            endMood = Double(viewModel.hike.startMood)
        }
    }

    // MARK: - Journal Header

    private var journalHeader: some View {
        Text("Vul de laatste gegevens in om je wandeling compleet te maken en af te ronden.")
            .font(.custom("Georgia-Italic", size: 15))
            .foregroundColor(HDColors.mutedGreen)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, HDSpacing.md)
    }

    // MARK: - End Time Content

    private var endTimeContent: some View {
        DatePicker(
            "Eindtijd",
            selection: $endTime,
            displayedComponents: [.date, .hourAndMinute]
        )
        .labelsHidden()
        .tint(HDColors.forestGreen)
    }

    // MARK: - Location Content

    private var locationContent: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            HDTextField(
                "Eindlocatie",
                text: $endLocationName,
                icon: "location"
            ) {
                GPSButton(
                    isLoading: locationService.isLoadingLocation,
                    hasLocation: locationService.fetchedLatitude != nil,
                    action: { fetchCurrentLocation() }
                )
            }

            if let error = locationService.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else if locationService.fetchedLatitude != nil, locationService.fetchedLongitude != nil {
                HStack(spacing: HDSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(HDColors.forestGreen)
                    Text("GPS coördinaten opgeslagen")
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen)
                }
            } else {
                Text("Typ handmatig of gebruik \(Image(systemName: "location.fill")) voor GPS")
                    .font(.caption)
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
    }

    // MARK: - Distance Content

    private var distanceContent: some View {
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
    }

    // MARK: - Mood Comparison View

    private var moodComparisonView: some View {
        HStack(spacing: HDSpacing.xs) {
            Text("Startstemming: \(viewModel.hike.startMood)")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            Spacer()

            // Verschil indicator
            let startMood = viewModel.hike.startMood
            let currentEndMood = Int(endMood)
            let difference = currentEndMood - startMood

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
            // Placeholder
            if reflection.isEmpty {
                Text(reflectionPlaceholder)
                    .font(.custom("Georgia-Italic", size: 15))
                    .foregroundColor(HDColors.mutedGreen.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }

            // TextEditor
            TextEditor(text: $reflection)
                .font(.body)
                .foregroundColor(HDColors.forestGreen)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 120)
        }
        .padding(HDSpacing.sm)
        .background(Color.white.opacity(0.5))
        .cornerRadius(HDSpacing.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                .stroke(HDColors.dividerColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Sticky Button

    private var stickyButton: some View {
        VStack {
            PrimaryButton(
                title: "Wandeling Afronden",
                action: { finishHike() },
                icon: "checkmark.circle"
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

    private func fetchCurrentLocation() {
        locationService.fetchCurrentLocation { result in
            switch result {
            case .success(let locationData):
                endLocationName = locationData.name
            case .failure:
                break
            }
        }
    }

    private func finishHike() {
        viewModel.hike.endTime = endTime
        viewModel.hike.endLocationName = endLocationName.isEmpty ? nil : endLocationName

        // Save GPS coordinates if available
        if let latitude = locationService.fetchedLatitude,
           let longitude = locationService.fetchedLongitude {
            viewModel.hike.endLatitude = latitude
            viewModel.hike.endLongitude = longitude
        }

        viewModel.hike.distance = Double(distance)
        viewModel.hike.rating = Int(rating)
        viewModel.hike.endMood = Int(endMood)
        viewModel.hike.reflection = reflection
        viewModel.hike.status = "completed"
        viewModel.hike.updatedAt = Date()

        appState.activeHikeID = nil

        // Handle notifications
        let motivationDays = UserDefaults.standard.integer(forKey: "motivationReminderDays")
        NotificationService.shared.onHikeEnded(
            completedDate: endTime,
            motivationDaysInterval: motivationDays == 0 ? 3 : motivationDays,
            motivationEnabled: UserDefaults.standard.bool(forKey: "notificationsEnabled")
                && UserDefaults.standard.bool(forKey: "motivationReminderEnabled")
        )

        // Store last completed hike date
        UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "lastCompletedHikeDate")

        showCompletionOverlay = true
    }
}

#Preview {
    FinishTabView(
        viewModel: ActiveHikeViewModel(
            hike: Hike(
                status: "inProgress",
                name: "Test Wandeling",
                type: "Dagwandeling",
                startMood: 6
            )
        )
    )
    .environment(AppState())
}
