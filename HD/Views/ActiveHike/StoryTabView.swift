import SwiftUI

struct StoryTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(
                        title: "Verhaal",
                        subtitle: "Schrijf je wandelverhaal"
                    )

                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Je Verhaal")
                                .font(.headline)

                            // Quick action buttons
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    QuickActionButton(
                                        icon: "clock",
                                        title: "Tijdstip",
                                        action: { insertTimestamp() }
                                    )

                                    QuickActionButton(
                                        icon: "eye",
                                        title: "Observatie",
                                        action: { insertObservation() }
                                    )
                                }

                                HStack(spacing: 12) {
                                    QuickActionButton(
                                        icon: "pause.circle",
                                        title: "Pauze",
                                        action: { insertPause() }
                                    )

                                    QuickActionButton(
                                        icon: "hare",
                                        title: "Dieren gespot",
                                        action: { insertAnimalSpotted() }
                                    )
                                }
                            }

                            TextEditor(text: $viewModel.hike.story)
                                .frame(minHeight: 400)
                                .scrollContentBackground(.hidden)
                                .focused($isEditorFocused)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Verhaal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func insertTimestamp() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: Date())

        let newText = "\n\n⏰ \(timeString)\n"
        appendToStory(newText)
    }

    private func insertObservation() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: Date())

        let newText = "\n\n⏰ \(timeString)\n👁️ Observatie: "
        appendToStory(newText)
    }

    private func insertPause() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: Date())

        let newText = "\n\n⏰ \(timeString)\n⏸️ Pauze\n"
        appendToStory(newText)
        viewModel.incrementPauseCount()
    }

    private func insertAnimalSpotted() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: Date())

        let newText = "\n\n⏰ \(timeString)\n🦌 Dieren gespot: "
        appendToStory(newText)
        viewModel.incrementAnimalCount()
    }

    private func appendToStory(_ text: String) {
        viewModel.hike.story += text
        viewModel.hike.updatedAt = Date()
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .foregroundColor(.accentColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    StoryTabView(
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
