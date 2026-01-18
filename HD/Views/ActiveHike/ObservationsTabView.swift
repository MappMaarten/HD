import SwiftUI

struct ObservationsTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(
                        title: "Terrein",
                        subtitle: "Beschrijf het terrein"
                    )

                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Terreinbeschrijving")
                                .font(.headline)

                            TextEditor(text: $viewModel.hike.terrainDescription)
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                        }
                    }

                    SectionHeader(
                        title: "Weer",
                        subtitle: "Beschrijf het weer"
                    )

                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weerbeschrijving")
                                .font(.headline)

                            TextEditor(text: $viewModel.hike.weatherDescription)
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                        }
                    }

                    SectionHeader(
                        title: "Tellingen",
                        subtitle: "Bijzondere observaties"
                    )

                    VStack(spacing: 12) {
                        CounterCardView(
                            icon: "pawprint",
                            title: "Dieren gezien",
                            count: viewModel.hike.animalCount,
                            onIncrement: { viewModel.incrementAnimalCount() },
                            onDecrement: { viewModel.decrementAnimalCount() }
                        )

                        CounterCardView(
                            icon: "pause.circle",
                            title: "Pauzes",
                            count: viewModel.hike.pauseCount,
                            onIncrement: { viewModel.incrementPauseCount() },
                            onDecrement: { viewModel.decrementPauseCount() }
                        )

                        CounterCardView(
                            icon: "person.2",
                            title: "Ontmoetingen",
                            count: viewModel.hike.meetingCount,
                            onIncrement: { viewModel.incrementMeetingCount() },
                            onDecrement: { viewModel.decrementMeetingCount() }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Observaties")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CounterCardView: View {
    let icon: String
    let title: String
    let count: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        CardView {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.body)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: onDecrement) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(count > 0 ? .red : .gray.opacity(0.3))
                    }
                    .disabled(count == 0)

                    Text("\(count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(minWidth: 30)

                    Button(action: onIncrement) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}

#Preview {
    ObservationsTabView(
        viewModel: ActiveHikeViewModel(
            hike: Hike(
                status: "inProgress",
                name: "Test Wandeling",
                type: "Dagwandeling",
                startMood: 8
            )
        )
    )
}
