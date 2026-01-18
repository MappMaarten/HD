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
            Form {
                Section {
                    SectionHeader(
                        title: "Basis informatie",
                        subtitle: "Start je nieuwe wandeling"
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Naam van de wandeling", text: $viewModel.name)

                        if let error = viewModel.nameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    if hikeTypes.isEmpty {
                        Text("Voeg wandeltypes toe in Instellingen")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Picker("Type wandeling", selection: $viewModel.selectedHikeType) {
                                Text("Selecteer type").tag(nil as HikeType?)

                                ForEach(hikeTypes) { type in
                                    Label(type.name, systemImage: type.iconName)
                                        .tag(type as HikeType?)
                                }
                            }
                            .onChange(of: viewModel.selectedHikeType) { oldValue, newValue in
                                viewModel.updateNameFromType()
                            }

                            if let error = viewModel.typeError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    TextField("Gezelschap (optioneel)", text: $viewModel.companions)
                }

                // Locatie sectie
                Section {
                    SectionHeader(
                        title: "Startlocatie",
                        subtitle: "Waar begin je deze wandeling?"
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Locatie (bijv. Soesterberg)", text: $viewModel.startLocationName)

                        Button {
                            viewModel.fetchCurrentLocation()
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Huidige locatie ophalen")

                                if viewModel.locationService.isLoadingLocation {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(viewModel.locationService.isLoadingLocation)

                        if let error = viewModel.locationService.locationError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        if viewModel.startLatitude != nil, viewModel.startLongitude != nil {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("GPS coördinaten opgeslagen")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // LAW Route sectie (alleen zichtbaar bij LAW-route type)
                if viewModel.isLAWRoute {
                    Section {
                        if lawRoutes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Geen LAW routes beschikbaar")
                                    .foregroundColor(.secondary)

                                Text("Voeg LAW routes toe in Instellingen")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Picker("LAW Route", selection: $viewModel.selectedLAWRoute) {
                                Text("Selecteer route").tag(nil as LAWRoute?)

                                ForEach(lawRoutes) { route in
                                    Text(route.name).tag(route as LAWRoute?)
                                }
                            }
                            .onChange(of: viewModel.selectedLAWRoute) { oldValue, newValue in
                                viewModel.updateNameFromType()
                            }

                            if let selectedRoute = viewModel.selectedLAWRoute {
                                Stepper(
                                    "Etappe: \(viewModel.lawStageNumber)",
                                    value: $viewModel.lawStageNumber,
                                    in: 1...selectedRoute.stagesCount
                                )
                                .onChange(of: viewModel.lawStageNumber) { oldValue, newValue in
                                    viewModel.updateNameFromType()
                                }
                            }
                        }
                    } header: {
                        Text("LAW Route Informatie")
                    }
                }

                Section {
                    SectionHeader(
                        title: "Stemming",
                        subtitle: "Hoe voel je je nu?"
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    VStack(spacing: 16) {
                        HStack {
                            Text("😔")
                                .font(.title2)

                            Slider(value: $viewModel.startMood, in: 1...10, step: 1)

                            Text("😊")
                                .font(.title2)
                        }

                        Text("\(Int(viewModel.startMood))/10")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Nieuwe Wandeling")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    PrimaryButton(
                        title: "Start Wandeling",
                        action: {
                            startHike()
                        },
                        isEnabled: viewModel.isValid
                    )
                    .padding(.horizontal)
                }
            }
        }
    }

    private func startHike() {
        // Veiligheidscheck: mag geen nieuwe hike starten als er al een actief is
        guard appState.activeHikeID == nil else {
            dismiss()
            return
        }

        // Final validation
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

        // Zet de nieuwe hike als actief
        appState.activeHikeID = newHike.id

        dismiss()
    }
}

#Preview {
    NewHikeView()
        .modelContainer(for: [Hike.self, HikeType.self, LAWRoute.self], inMemory: true)
        .environment(AppState())
}
