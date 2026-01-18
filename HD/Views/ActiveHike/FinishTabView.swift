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
    @State private var showCompletionMessage = false

    let locationService = LocationService()

    let reflectionPrompts = [
        "Wat viel je het meest op tijdens deze wandeling?",
        "Welk moment blijft je het meest bij?",
        "Hoe voelde je je tijdens de wandeling?",
        "Zou je deze route aanraden aan anderen?"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(
                        title: "Wandeling Afronden",
                        subtitle: "Vul de laatste gegevens in"
                    )

                    // Eindtijd
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Eindtijd")
                                .font(.headline)

                            DatePicker(
                                "Eindtijd",
                                selection: $endTime,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                        }
                    }

                    // Eindlocatie
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Eindlocatie")
                                .font(.headline)

                            TextField("Locatie (bijv. Soesterberg)", text: $endLocationName)
                                .textFieldStyle(.roundedBorder)

                            Button {
                                locationService.fetchCurrentLocation { result in
                                    switch result {
                                    case .success(let locationData):
                                        endLocationName = locationData.name
                                    case .failure:
                                        break
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Huidige locatie ophalen")

                                    if locationService.isLoadingLocation {
                                        Spacer()
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                            }
                            .disabled(locationService.isLoadingLocation)

                            if let error = locationService.locationError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // Afstand
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Afstand (km)")
                                .font(.headline)

                            TextField("Bijv. 12.5", text: $distance)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // Waardering
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Waardering")
                                .font(.headline)

                            HStack {
                                Text("⭐️")
                                    .font(.title2)

                                Slider(value: $rating, in: 1...10, step: 1)

                                Text("⭐️⭐️⭐️")
                                    .font(.title2)
                            }

                            Text("\(Int(rating))/10")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Eindstemming
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Eindstemming")
                                .font(.headline)

                            HStack {
                                Text("😔")
                                    .font(.title2)

                                Slider(value: $endMood, in: 1...10, step: 1)

                                Text("😊")
                                    .font(.title2)
                            }

                            Text("\(Int(endMood))/10")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Reflectie
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reflectie")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Denk na over:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                ForEach(reflectionPrompts, id: \.self) { prompt in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.secondary)
                                        Text(prompt)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 8)

                            TextEditor(text: $reflection)
                                .frame(minHeight: 150)
                                .scrollContentBackground(.hidden)
                        }
                    }

                    PrimaryButton(
                        title: "Wandeling Afronden",
                        action: {
                            finishHike()
                        }
                    )
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationTitle("Afronden")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Geweldig! 🎉", isPresented: $showCompletionMessage) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Je hebt een wandeling afgerond!")
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

        showCompletionMessage = true
    }
}

#Preview {
    FinishTabView(
        viewModel: ActiveHikeViewModel(
            hike: Hike(
                status: "inProgress",
                name: "Test Wandeling",
                type: "Dagwandeling",
                startMood: 8
            )
        )
    )
    .environment(AppState())
}
