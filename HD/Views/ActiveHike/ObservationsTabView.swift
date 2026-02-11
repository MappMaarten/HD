import SwiftUI

struct ObservationsTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    var hikeName: String
    @FocusState private var isEditorFocused: Bool


    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeader(title: "Terrein")

                        CardView {
                            ZStack(alignment: .topLeading) {
                                if viewModel.hike.terrainDescription.isEmpty {
                                    Text("Bijv. bospad, heuvelachtig, modderig...")
                                        .foregroundColor(HDColors.mutedGreen.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $viewModel.hike.terrainDescription)
                                    .frame(minHeight: 60)
                                    .scrollContentBackground(.hidden)
                                    .focused($isEditorFocused)
                            }
                        }

                        SectionHeader(title: "Weer")

                        CardView {
                            ZStack(alignment: .topLeading) {
                                if viewModel.hike.weatherDescription.isEmpty {
                                    Text("Bijv. zonnig, 18°C, lichte wind...")
                                        .foregroundColor(HDColors.mutedGreen.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $viewModel.hike.weatherDescription)
                                    .frame(minHeight: 60)
                                    .scrollContentBackground(.hidden)
                                    .focused($isEditorFocused)
                            }
                        }

                        SectionHeader(
                            title: "Tellingen",
                            subtitle: "Wat je hebt geteld"
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

                        SectionHeader(title: "Bijzondere observaties")

                        CardView {
                            ZStack(alignment: .topLeading) {
                                if viewModel.hike.notes.isEmpty {
                                    Text("Bijv. bijzondere vogel gezien, onverwachte ontmoeting...")
                                        .foregroundColor(HDColors.mutedGreen.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $viewModel.hike.notes)
                                    .frame(minHeight: 60)
                                    .scrollContentBackground(.hidden)
                                    .focused($isEditorFocused)
                            }
                        }
                    }
                    .padding()
                }
                .keyboardAdaptive()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isEditorFocused = false
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(HDColors.forestGreen)
                }
            }
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle(hikeName)
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
                            .foregroundColor(count > 0 ? HDColors.mutedGreen : HDColors.mutedGreen.opacity(0.3))
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
                            .foregroundColor(HDColors.forestGreen)
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
        ),
        hikeName: "Test Wandeling"
    )
}
